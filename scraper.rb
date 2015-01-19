require './models'

require 'bundler/setup'

require 'pry'
require 'ecfs'
require 'active_support/core_ext/date'
require 'logger'

LOGGER = Logger.new('log/scraper.log')
LOGGER.level = Logger::INFO

class Scraper
  def self.get_filings(docket_number, days=nil)
    ECFS::SolrScrapeQuery.new.tap do |q|
      q.docket_number = docket_number
      
      if days
        q.received_min_date = days.to_i.days.ago.strftime("%m/%d/%Y")
      end
      
      q.after_scrape = Proc.new do |filings|
        filings.map do |filing|
          fcc_id = filing['url'].split('view?id=')[1]
          date = DateTime.strptime(filing["date_received"], "%m/%d/%Y")

          f = Filing.new({
            docket_number: filing['docket_number'],
            name_of_filer: filing['name_of_filer'],
            type_of_filing: filing['type_of_filing'],
            fcc_url: filing['url'],
            fcc_id: fcc_id,
            citation: filing['citation'],
            date_received: date
          })
          
          f
        end
        
        filings_to_save = filings.select {|filing| filing.valid?}
        filings_not_to_save = filings.select {|filing| !filing.valid?}
        
        Filing.import filings_to_save

        filings_to_save.each do |f|
          LOGGER.info("Filing saved: #{f.inspect}")
        end
        
        filings_not_to_save.each do |f|
          LOGGER.info("Filing not saved: #{f.inspect}")
        end
        
      end
    end.get
  end
end
