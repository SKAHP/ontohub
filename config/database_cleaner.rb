require 'database_cleaner'
require Rails.root.join('spec/support/fixtures_generation/pipeline_generator.rb')

module DatabaseCleanerConfig
  CLEAN_MODE = :transaction
  NO_TRANSACTION_CLEAN_MODE = :deletion
  INITIAL_CLEAN_MODE = :truncation
  CLEAN_OPTIONS = {
    except: %w(
      ontology_file_extensions
      file_extension_mime_type_mappings
      proof_statuses
    ),
  }
  DEFAULT_STRATEGY = CLEAN_MODE
  NO_TRANSACTION_STRATEGY = NO_TRANSACTION_CLEAN_MODE, CLEAN_OPTIONS
  STRATEGY =
    if ENV['NO_TRANSACTION']
      NO_TRANSACTION_STRATEGY
    else
      DEFAULT_STRATEGY
    end

  if defined?(RSpec) && RSpec.respond_to?(:configure)
    RSpec.configure do |config|
      config.use_instantiated_fixtures  = false
      config.use_transactional_fixtures = false
      config.add_setting :original_hostname

      config.before(:suite) do
        DatabaseCleaner.strategy = INITIAL_CLEAN_MODE, CLEAN_OPTIONS
        DatabaseCleaner.clean
        DatabaseCleaner.strategy = STRATEGY
        config.original_hostname = Settings.hostname
      end

      config.before(:each, :http_interaction) do
        DatabaseCleaner.strategy = NO_TRANSACTION_STRATEGY
        Settings.hostname =
          FixturesGeneration::PipelineGenerator::RAILS_SERVER_HOSTNAME
      end

      config.after(:each, :http_interaction) do
        DatabaseCleaner.strategy = STRATEGY
        Settings.hostname = config.original_hostname
      end

      config.before(:each) do
        DatabaseCleaner.start
      end

      config.after(:each) do
        DatabaseCleaner.clean

        # Remove repositories and other data created in a test
        %w(data test).each do |d|
          dir = Rails.root.join('tmp', d)
          dir.rmtree if dir.exist?
        end
      end
    end
  end
end
