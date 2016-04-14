ENV['RAILS_ENV'] = 'test'
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'rspec'
require 'active_sorting'

Bundler.require(:default)
# Connect to database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')
# Load our schema
# ActiveRecord::Base.logger = Logger.new(STDOUT)
load(File.join(File.dirname(__FILE__), 'schema.rb'))

# Define the testing model
class Item < ActiveRecord::Base
  sortable :position
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
end
