require 'rspec/matchers'

RSpec::Matchers.define :match_json_schema do |schema|
  match do |text|
    JSON::Validator.clear_cache
    JSON::Validator.validate!(schema, text, clear_cache: true)
  end
end
