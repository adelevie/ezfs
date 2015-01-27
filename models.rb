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
  
  LIMIT = 500
  
  def self.docket_search(docket_number, query)    
    results = self.search(where: {docket_number: docket_number, citation: query}, limit: LIMIT)
    if results.length == 0
      results = self.search(query, where: {docket_number: docket_number}, limit: LIMIT)
    end

    return results
  end

  def self.all_search(query)
    re1 = '(\\d+)'	# Integer Number 1
    re2 = '(-)'	# Any Single Character 1
    re3 = '(\\d+)'	# Integer Number 2
    re = (re1+re2+re3)
    m = Regexp.new(re,Regexp::IGNORECASE)
    
    query.gsub!("*", "")
    
    query.gsub!("nprm", "Notice of Proposed Rulemaking")
    query.gsub!("NPRM", "Notice of Proposed Rulemaking")
    
    query.gsub!("fnprm", "Further Notice of Proposed Rulemaking")
    query.gsub!("FNPRM", "Further Notice of Proposed Rulemaking")
    
    query.gsub!("r&o", "Report and Order")
    query.gsub!("R&O", "Report and Order")
    
    results = []
    docket_number = nil
    
    if m.match(query)
      docket_number = m.match(query)[0]   
      stripped_query = query.gsub(docket_number, "").strip
      
      if stripped_query.empty?
        results = self.search(where: {docket_number: docket_number}, limit: LIMIT)
      else
        results = self.docket_search(docket_number, stripped_query)
      end
    else
      results = self.search(query, limit: LIMIT)
    end
  
    return results, docket_number

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

