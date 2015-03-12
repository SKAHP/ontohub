namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    # Taken from https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/railties/databases.rake#L512
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end


  HETS_API_OPTIONS = '/auto'
  HETS_BASE_IRI = 'http://localhost:8000'
  HETS_PATH = `which hets`.strip
  HETS_SERVER_ARGS = YAML.load(File.open('config/hets.yml'))['server_options']

  def all_files_beneath(dir)
    globbed_files = Dir.glob(File.join(dir, '**/*'))
    globbed_files.select { |file| !File.directory?(file) }
  end

  def ontology_files
    all_files_beneath('spec/fixtures/ontologies').select do |file|
      !file.end_with?('.xml')
    end
  end

  def prove_files
    all_files_beneath('spec/fixtures/ontologies/prove')
  end

  def absolute_filepath(file)
    Rails.root.join(file)
  end

  def cassette_file(file)
    # remove spec/fixtures/ontologies/ for cassette name
    cassette_filepath = file.split('/')[3..-1].join('/')
  end

  def hets_cassette_dir(subdir)
    File.join('hets-out', subdir)
  end

  def cassette_path_in_fixtures(subdir, file)
    File.join(hets_cassette_dir(subdir), cassette_file(file))
  end

  def recorded_file(subdir, file)
    base = file.split('.')[0..-2].join('.')
    old_extension = File.extname(file)[1..-1]
    file = "#{base}_#{old_extension}.yml"
    File.join('spec', 'fixtures', 'vcr', cassette_path_in_fixtures(subdir, file))
  end

  def outdated_cassettes(files, subdir)
    files.select do |file|
      cassette = recorded_file(subdir, file)
      !FileUtils.uptodate?(cassette, Array(HETS_PATH))
    end
  end

  def on_outdated_cassettes(files, subdir, &block)
    outdated_cassettes(files, subdir).each do |file|
      block.call(file, subdir)
    end
  end

  def call_hets_dg(file, subdir)
    puts "Calling hets/dg on #{file.inspect}"
    hets_api_options = "#{HETS_API_OPTIONS}/full-signatures/full-theories"
    escaped_iri = Rack::Utils.escape_path("file://#{absolute_filepath(file)}")
    hets_iri = "#{HETS_BASE_IRI}/dg/#{escaped_iri}#{hets_api_options}"

    FileUtils.rm_f(recorded_file(subdir, file))
    VCR.use_cassette(cassette_path_in_fixtures(subdir, file)) do
      Net::HTTP.get_response(URI(hets_iri))
    end
  end

  def call_hets_provers(file, subdir)
    puts "Calling hets/provers on #{file.inspect}"
    options = 'format=json'
    escaped_iri = Rack::Utils.escape_path("file://#{absolute_filepath(file)}")
    hets_iri = "#{HETS_BASE_IRI}/provers/#{escaped_iri}#{HETS_API_OPTIONS}"
    hets_iri << "?#{options}"

    FileUtils.rm_f(recorded_file(subdir, file))
    VCR.use_cassette(cassette_path_in_fixtures(subdir, file)) do
      Net::HTTP.get_response(URI(hets_iri))
    end
  end

  def call_hets_prove(file, subdir)
    puts "Calling hets/prove on #{file.inspect}"
    escaped_iri = Rack::Utils.escape_path("file://#{absolute_filepath(file)}")
    hets_iri = "#{HETS_BASE_IRI}/prove/#{escaped_iri}#{HETS_API_OPTIONS}"
    header = {'Content-Type' => 'application/json'}
    data = {format: 'json', include: 'true'}

    FileUtils.rm_f(recorded_file(subdir, file))
    VCR.use_cassette(cassette_path_in_fixtures(subdir, file)) do
      uri = URI(hets_iri)
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request_post(uri, data.to_json, header)
      end
    end
  end

  def freshen_ontology_fixtures
    on_outdated_cassettes(ontology_files, 'dg') do |file, subdir|
      call_hets_dg(file, subdir)
    end
  end

  def freshen_provers_fixtures
    on_outdated_cassettes(ontology_files, 'provers') do |file, subdir|
      call_hets_provers(file, subdir)
    end
  end

  def freshen_proof_fixtures
    on_outdated_cassettes(prove_files, 'prove') do |file, subdir|
      call_hets_prove(file, subdir)
    end
  end

  def setup_vcr
    require 'vcr'
    VCR.configure do |c|
      c.cassette_library_dir = 'spec/fixtures/vcr'
      c.hook_into :webmock
    end
  end

  def port_open?(ip, port, seconds=1)
    require 'socket'
    require 'timeout'
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  def with_running_hets(&block)
    hets_was_already_running = !port_open?('127.0.0.1', 8000)
    if hets_was_already_running
      hets_pid = fork { exec("hets --server #{HETS_SERVER_ARGS.join(' ')}") }
      # hets server needs some startup time
      sleep 1
    end
    block.call
  ensure
    if hets_was_already_running
      puts 'Stopping hets server.'
      Process.kill('TERM', hets_pid)
    end
  end

  desc 'Update all fixtures'
  task :freshen_fixtures do
    outdated_exist = outdated_cassettes(ontology_files, 'dg').any?
    outdated_exist ||= outdated_cassettes(ontology_files, 'provers').any?
    outdated_exist ||= outdated_cassettes(prove_files, 'prove').any?
    if outdated_exist
      setup_vcr
      with_running_hets do
        freshen_ontology_fixtures
        freshen_provers_fixtures
        freshen_proof_fixtures
      end
    end
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    if outdated_cassettes(ontology_files, 'dg').any?
      setup_vcr
      with_running_hets { freshen_ontology_fixtures }
    end
  end

  desc 'Update all provers fixtures'
  task :freshen_provers_fixtures do
    if outdated_cassettes(ontology_files, 'provers').any?
      setup_vcr
      with_running_hets { freshen_provers_fixtures }
    end
  end

  desc 'Update all proof fixtures'
  task :freshen_proof_fixtures do
    if outdated_cassettes(prove_files, 'prove').any?
      setup_vcr
      with_running_hets { freshen_proof_fixtures }
    end
  end
end
