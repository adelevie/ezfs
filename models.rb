require 'bundler/setup'
require 'dotenv'
Dotenv.load

require 'active_record'
require 'activerecord-import'
require 'logger'
require 'yaml'
require 'pry'
require 'searchkick'

EZFS_ENV = ENV.fetch('RACK_ENV', 'development')

ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('db/config.yml'))
ActiveRecord::Base.establish_connection(configuration[EZFS_ENV])

class Filing < ActiveRecord::Base
  searchkick
  validates_uniqueness_of :fcc_id, scope: :docket_number
  
  def self.docket_search(docket_number,query)
    # results = Filing.search(where: {docket_number: docket_number, citation: query})
    # if results.length == 0
    #   results = Filing.search(query, where: {docket_number: docket_number})
    # end
    #
    # if results.length == 1
    #   redirect results.first.fcc_url
    # else
    #   erb :search, locals: {docket_number: docket_number, results: results}
    # end
    
    results = self.search(where: {docket_number: docket_number, citation: query})
    if results.length == 0
      results = self.search(query, where: {docket_number: docket_number})
    end

    return results
  end
end

SEED_DOCKETS = [
  "12-83",
  "14-261",
  "14-171",
  "02-278",
  "02-171",
  "02-178",
  "12-375",
  "14-90",
  "10-90",
  "02-6",
  "10-254",
  "07-250",
  "12-3",
  "03-185",
  "12-1",
  "10-56",
  "14-159",
  "14-262",
  "14-263",
  "12-80",
  "14-127",
  "03-123",
  "10-51",
  "05-231",
  "RM-11728",
  "10-145",
  "14-259",
  "11-42",
  "05-68",
  "09-109",
  "05-337",
  "06-122",
  "07-135",
  "13-39",
  "14-158",
  "14-93",
  "14-169",
  "15-5",
  "07-52",
  "07-149",
  "11-59",
  "04-223",
  "07-21",
  "07-38"
]

class Docket
  def self.all
    dockets = Filing.pluck(:docket_number).uniq
    if dockets.empty?
      return SEED_DOCKETS
    else
      return dockets
    end
  end
end

