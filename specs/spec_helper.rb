require 'rubygems'
require 'rails/all'
require 'rspec'
require File.join(File.dirname(__FILE__), '../lib/mark.rb')

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
  #ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  db_adapter = ENV['DB']

  # no db passed, try one of these fine config-free DBs before bombing.
  db_adapter ||=
    begin
      require 'rubygems'
      require 'mysql'
      'mysql'
    rescue MissingSourceFile
      begin
        require 'sqlite3'
        'sqlite3'
      rescue MissingSourceFile
      end
    end

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end

  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/db/schema.rb")
  #require File.dirname(__FILE__) + '/../rails/init'
end