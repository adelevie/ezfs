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
  
  def self.extract_fcc_rcd(text)
    txt=text

    re1='(\\d+)'	# Integer Number 1
    re2='(\\s+)'	# White Space 1
    re3='(FCC)'	# Word 1
    re4='(\\s+)'	# White Space 2
    re5='((?:[a-z][a-z]+))'	# Word 2
    re6='(\\s+)'	# White Space 3
    re7='(\\d+)'	# Integer Number 2

    re=(re1+re2+re3+re4+re5+re6+re7)
    m=Regexp.new(re,Regexp::IGNORECASE);
    if m.match(txt)
      int1=m.match(txt)[1];
      ws1=m.match(txt)[2];
      word1=m.match(txt)[3];
      ws2=m.match(txt)[4];
      word2=m.match(txt)[5];
      ws3=m.match(txt)[6];
      int2=m.match(txt)[7];
      puts "("<<int1<<")"<<"("<<ws1<<")"<<"("<<word1<<")"<<"("<<ws2<<")"<<"("<<word2<<")"<<"("<<ws3<<")"<<"("<<int2<<")"<< "\n"
   
      return {
        type: :fcc_rcd,
        volume: int1,
        page: int2,
        url: "https://fccrcd.link/#{int1}/#{int2}"
      }
    else
      return nil
    end
  end

  def self.all_search(query)
    query_copy = query
    
    fcc_rcd = extract_fcc_rcd(query)
    
    re1 = '(\\d+)'	# Integer Number 1
    re2 = '(-)'	# Any Single Character 1
    re3 = '(\\d+)'	# Integer Number 2
    re = (re1+re2+re3)
    m = Regexp.new(re,Regexp::IGNORECASE)
    
    if fcc_rcd
      query_copy.gsub!("#{fcc_rcd[:volume]} FCC Rcd #{fcc_rcd[:page]}", "")
      query_copy.gsub!("#{fcc_rcd[:volume]} FCC RCD #{fcc_rcd[:page]}", "")
      query_copy.gsub!("#{fcc_rcd[:volume]} fcc rcd #{fcc_rcd[:page]}", "")    
    end
    
    query_copy.gsub!("*", "")
    
    query_copy.gsub!("nprm", "Notice of Proposed Rulemaking")
    query_copy.gsub!("NPRM", "Notice of Proposed Rulemaking")
    
    query_copy.gsub!("fnprm", "Further Notice of Proposed Rulemaking")
    query_copy.gsub!("FNPRM", "Further Notice of Proposed Rulemaking")
    
    query_copy.gsub!("r&o", "Report and Order")
    query_copy.gsub!("R&O", "Report and Order")
    
    results = []
    
    docket_number = nil
    
    if m.match(query)
      docket_number = m.match(query_copy)[0]   
      stripped_query = query_copy.gsub(docket_number, "").strip
      
      if stripped_query.empty?
        results = self.search(where: {docket_number: docket_number}, limit: LIMIT)
      else
        results = self.docket_search(docket_number, stripped_query)
      end
    else
      results = self.search(query_copy, limit: LIMIT)
    end
  
    return results, docket_number, fcc_rcd
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

