require 'bundler/setup'

require 'active_record'
require 'logger'
require 'yaml'
require 'pry'

ezfs_env = ENV.fetch('EZFS_ENV', 'development')

require 'sqlite3' if ezfs_env == 'development'

ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('db/config.yml'))
ActiveRecord::Base.establish_connection(configuration[ezfs_env])

class Filing < ActiveRecord::Base
  validates_uniqueness_of :fcc_id
end
