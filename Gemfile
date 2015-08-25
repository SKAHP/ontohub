source 'https://rubygems.org'

gem 'rails', '~> 3.2.22'
gem 'rack-protection', '~> 1.5.3'
gem 'secure_headers', '~> 2.2.3'

gem 'pry-rails', '~> 0.3.2'

gem 'pg', '~> 0.18.1'
gem 'foreigner', '~> 1.7.2'

gem 'rdf', '~> 1.1.15'
gem 'rdf-rdfxml', '~> 1.1.3'
gem 'rdf-n3', '~> 1.1.2'

gem 'redis-semaphore', '~> 0.2.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jstree-rails', github: 'tristanm/jstree-rails'
  # sass-rails >= 4.0 is not compativle with rails 3
  gem 'sass-rails',     '~> 3.2.3'
  gem 'bootstrap-sass', '~> 3.3.3'
  # coffee-rails > 3.2.1 is not compatible with rails 3
  gem 'coffee-rails',   '~> 3.2.1'
  gem 'compass',        '~> 1.0.3'
  gem 'font-awesome-sass', '~> 4.3.1'
  # jquery-rails > 3.1.2 is not compatible with rails 3
  gem 'jquery-rails', '~> 3.1.2'
  gem 'jquery-ui-rails', '~> 5.0.5'
  gem 'momentjs-rails', '~> 2.10.2'
  gem 'd3_rails', '~> 3.5.5'
  gem 'therubyracer', '~> 0.12.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'handlebars_assets', '~> 0.20.1'
  gem 'hamlbars', '~> 2.1.1'
  gem 'underscore-rails', '~> 1.8.2'
  gem 'bootstrap-select-rails', '~> 1.6.3'
end

# Newer versions than 0.4 are not compatible with rails 3.2
gem 'haml-rails', '~> 0.4'

# Project configuration
# The specified commit is from a fork and allows to overwrite arrays.
# It has been pull-requested:
# https://github.com/railsconfig/rails_config/pull/103
gem 'rails_config', github: 'dtaniwaki/rails_config', ref: 'merge-array-option'

#provides  correct indefinite article 
gem 'indefinite_article', '~> 0.2.0'

# Fancy Forms
# simple_form >= 3.0 is not compatible with rails 3
gem 'simple_form', '~> 2.1.1'

# Inherited Resources
gem 'inherited_resources', '~> 1.4.1'
gem 'has_scope', '~> 0.6.0.rc'

# JSON views
gem 'active_model_serializers', '~> 0.9.3'

# JSON Parser
gem 'json-stream', '~> 0.2.1'

# XML Parser
gem 'nokogiri', '~> 1.6.6.2'

# Authentication
gem 'devise', '~> 3.5.2'

# Authorization
gem 'cancan', '~> 1.6.7'

# Pagination
gem 'kaminari', '~> 0.16.1'

# Strip spaces in attributes
gem "strip_attributes", "~> 1.0"

# For distributed ontologies
gem 'acts_as_tree', '~> 2.2.0'

# HTTP Client
gem "rest-client", '~> 1.8.0'

# Background-Jobs
gem 'sidekiq', '~> 3.4.2'
gem 'sidetiq', '~> 0.6.3'
gem 'sidekiq-failures', '~> 0.4.5'
gem 'sidekiq-status', '~> 0.5.4'
gem 'sinatra', '~> 1.4.5', require: false, group: [:development, :production]

# Search engine
gem 'progress_bar', '~> 1.0.2'
gem 'elasticsearch-model', '~> 0.1.4'
gem 'elasticsearch-rails', '~> 0.1.4'
gem 'elasticsearch', '~> 1.0.4'
gem 'elasticsearch-extensions', '~> 0.0.15'

# Graph visualization
gem 'ruby-graphviz', "~> 1.2.2"

# Fake-inputs for tests and seeds
gem "faker", "~> 1.5.0"

# Git
gem 'rugged', '~> 0.23.2'
gem 'codemirror-rails', github: 'llwt/codemirror-rails'

# API
gem 'specroutes', github: '0robustus1/specroutes'

# Ancestry enabling tree structure in category model
# gem 'ancestry'

# Use dagnabit to model categories
# Newer versions than 3.0.x are not compatible with rails 3.2
gem 'dagnabit', '~> 3.0.1'

# Migrate data in separate tasks
gem 'data_migrate', '~> 1.2.0'

# Multi Table Inheritance. For Rails 4, mirgrate to active_record-acts_as.
gem 'acts_as_relation', '~> 0.1.3'

# Clean the database - especially needed in the seeds
gem 'database_cleaner', '~> 1.4.1'

group :test do
  gem 'mocha', '~> 1.1.0', require: false
  gem 'shoulda', '~> 3.5.0'
  gem "shoulda_routing_macros", "~> 0.1.2"
  gem 'rspec-activemodel-mocks', '~> 1.0.1'
  # rspec-its >= 1.1 depends on rspec 3
  gem 'rspec-its', '~> 1.0.1'
  gem "factory_girl_rails", '~> 4.5.0'

  # Required for integration tests
  gem 'capybara', '~> 2.4.4'
  gem 'poltergeist', '~> 1.6.0'
  gem 'launchy', '~> 2.4.3'

  gem 'cucumber-rails', '~> 1.4', require: false
  # Code Coverage Analysis
  gem 'simplecov', '~> 0.10.0', require: false

  # So we can validate against json-schemas
  gem 'json-schema', '~> 2.5.0'

  # Writing test ontologies
  gem 'ontology-united', github: '0robustus1/ontology-united'
end

group :development do
  gem "rails-erd", '~> 1.4.1'
  gem 'quiet_assets', '~> 1.1.0'
  gem 'invoker', '~> 1.3.2'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'i18n-tasks', '~> 0.8.3'
  gem 'pry-byebug', '~> 3.1.0'

  # Recording of HTTP Requests
  gem "vcr", '~> 2.9.3', require: false
  gem "webmock", '~> 1.21.0', require: false
end

group :production do
  # puma is __the only exception__ for which we don't specify a version.
  gem 'puma'
  gem 'god', '~> 0.13.4'
  gem 'exception_notification', '~> 4.1.0'
end

group :deployment do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rvm', '~> 0.1.1'
end

group :documentation do
  gem 'yard', '~> 0.8.7.6'
  gem 'redcarpet', '~> 3.3.2'
end
