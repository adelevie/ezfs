require 'bundler/setup'

require 'active_record'
require 'sqlite3'
require 'logger'
require 'yaml'
require 'pry'

ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('db/config.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])

class Filing < ActiveRecord::Base
  validates_uniqueness_of :fcc_id
end
