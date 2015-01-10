require './scraper'

require 'bundler/setup'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

module Scrape
  def self.all(docket_number)
    Scraper.get_filings(docket_number)
  end
  
  def self.last_n_days(docket_number, days)
    Scraper.get_filings(docket_number, days)
  end
  
  def self.resume(docket_number)
    last_filing = Filing.where(docket_number: docket_number).last
    days = (Date.today - last_filing.date_received.to_date).to_i
    Scraper.get_filings(docket_number, days)
  end
  
  def self.track(docket_number)
    filings = Filing.where(docket_number: docket_number).count
    
    if filings == 0
      Scrape.all(docket_number)
    else
      Scrape.resume(docket_number)
    end
  end
end

namespace :scrape do
  desc "Downloads all filings for a given docket"
  task :all => :environment do
    docket_number = ENV['docket_number']
    Scrape.all(docket_number)
  end
  
  desc "Downloads all filings for a given docket with the last n days"
  task :last_n_days => :environment do
    docket_number = ENV['docket_number']
    days = ENV['days']
    Scrape.last_n_days(docket_number, days)
  end
  
  desc "Resumes a scrape for a given docket based on the most recent filings already in the database"
  task :resume => :environment do
    docket_number = ENV['docket_number']
    Scrape.resume(docket_number)
  end
  
  desc "A meta-task composed of Scrape.all and Scrape.last_n_days to monitor a docket"
  task :track => :environment do
    docket_number = ENV['docket_number']
    Scrape.track(docket_number)
  end
end
