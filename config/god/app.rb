require File.expand_path('../sidekiq_workers',  __FILE__)
require File.expand_path('../hets_workers',  __FILE__)
require File.expand_path('../../../lib/environment_light_with_hets.rb', __FILE__)

RAILS_ROOT = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

# High load workers (except hets) are: sequential and priority_push.
HIGH_LOAD_WORKERS_COUNT = 2

God.pid_file_directory = File.join(RAILS_ROOT, 'tmp/pids/')

SidekiqWorkers.configure do
  if ENV['RAILS_ENV']=='production'
    # one worker per core
    Settings.hets.instance_urls.size.times.each do
      watch 'hets', 1
    end

    # one worker for hets load balancing
    watch 'hets_load_balancing', 1

    # one worker for the default queue
    watch 'default', 5

    # one worker for the sequential queue
    watch 'sequential', 1

    watch 'priority_push', 1
  else
    # one worker for all queues
    watch %w(hets hets_load_balancing default sequential priority_push), 1
  end
end

HetsWorkers.configure do
  Settings.hets.instance_urls.each do |hets_url|
    if hets_url.match(%r{\Ahttps?://(localhost|127.0.0.1|0.0.0.0|::1)})
      watch(URI(hets_url).port)
    end
  end
end
