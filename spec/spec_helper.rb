ENV['RAILS_ENV'] = 'test'
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'rspec'
require 'database_cleaner'
require 'active_sorting'

Bundler.require(:default)
# Connect to database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')
# Load our schema
# ActiveRecord::Base.logger = Logger.new(STDOUT)
load(File.join(File.dirname(__FILE__), 'schema.rb'))
load(File.join(File.dirname(__FILE__), 'models.rb'))

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
  config.order = :random

  # Cleanup the database
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
