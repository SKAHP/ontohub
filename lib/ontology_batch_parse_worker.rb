class OntologyBatchParseWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  # Because of the JSON-Parsing the hash which contains
  # the try_count will contain the try_count key
  # as a string and not as a symbol (which is necessary
  # for the keyword-style to work).
  def perform(*args, try_count: 1)
    if args.last.is_a?(Hash) && args.last['try_count']
      hash = args.pop
      @try_count = hash['try_count']
    else
      @try_count = try_count
    end
    @args = args
    execute_perform(try_count, *args)
  end

  def execute_perform(try_count, versions)
    done = false

    return if versions.empty?

    version_id, opts = versions.head
    version = OntologyVersion.find(version_id)

    opts.each do |method_name, value|
      version.send(:"#{method_name}=", value)
    end

    version.parse
  rescue ConcurrencyBalancer::AlreadyProcessingError
    done = handle_concurrency_issue
  ensure
    self.class.perform_async(versions.tail, try_count: try_count) unless versions.tail.empty? || done
  end

  def handle_concurrency_issue
    if @try_count >= ConcurrencyBalancer::MAX_TRIES
      SequentialOntologyBatchParseWorker.perform_async(*@args)
    else
      self.class.perform_async(*@args, try_count: @try_count+1)
    end
    true
  end

end

class SequentialOntologyBatchParseWorker < OntologyBatchParseWorker
  sidekiq_options queue: 'sequential'

  def perform(*args, try_count: 1)
    if args.last.is_a?(Hash) && args.last['try_count']
      hash = args.pop
      @try_count = hash['try_count']
    else
      @try_count = try_count
    end
    @args = args
    ConcurrencyBalancer.sequential_lock do
      execute_perform(try_count, *args)
    end
  rescue ConcurrencyBalancer::AlreadyLockedError
    handle_concurrency_issue
  end

  def handle_concurrency_issue
    SequentialOntologyBatchParseWorker.perform_async(*@args, try_count: @try_count+1)
  end

end
