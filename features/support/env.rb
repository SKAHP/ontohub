# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.
require 'simplecov'
require 'sidekiq/testing'
require 'cucumber/rails'
require 'capybara/poltergeist'
require 'webmock'
require 'vcr'

Capybara.current_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 5

class Cucumber::Rails::World
  require Rails.root.join('spec', 'support', 'common_helper_methods.rb')
  require Rails.root.join('spec', 'support', 'scenario_progress_formatter.rb')

  def locid_for(resource, *commands, **query_components)
    iri = "#{resource.locid}"
    iri << "///#{commands.join('///')}" if commands.any?
    iri << "?#{query_components.to_query}" if query_components.any?
    iri
  end

  # Capybara is smart enough to wait for ajax when not finding elements.
  # In some situations the element is already existent, but has not been updated
  # yet. This is where you need to manually use wait_for_ajax.
  def wait_for_ajax
    counter = 0
    # The condition only works with poltergeist/phantomjs.
    while page.evaluate_script("jQuery.active").to_i > 0
      counter += 1
      sleep(0.1)
      if counter >= 10 * Capybara.default_wait_time
        raise "AJAX request took longer than 5 seconds."
      end
    end
  end
end


# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :transaction

WebMock.allow_net_connect!(:net_http_connect_on_start => true)

include Warden::Test::Helpers
Warden.test_mode!
