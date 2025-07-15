ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require 'database_cleaner/active_record'

require_relative '../app'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  config.include RSpecMixin
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  WebMock.disable_net_connect!(allow_localhost: true)
end