require 'bundler/setup'

require 'active_record'
require 'logger'
require 'yaml'
require 'pry'

ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('db/config.yml'))
ActiveRecord::Base.establish_connection(configuration['production'])

class Filing < ActiveRecord::Base
  validates_uniqueness_of :fcc_id
end
