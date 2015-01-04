require './scraper'

require 'bundler/setup'

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

namespace :scrape do
  desc "Downloads all filings for a given docket"
  task :all => :environment do
    docket_number = ENV['docket_number']
    Scraper.get_filings(docket_number)
  end
  
  desc "Downloads all filings for a given docket with the last n days"
  task :last_n_days => :environment do
    docket_number = ENV['docket_number']
    days = ENV['days']
    Scraper.get_filings(docket_number, days)
  end
  
  desc "Resumes a scrape for a given docket based on the most recent filings already in the database"
  task :resume => :environment do
    docket_number = ENV['docket_number']
    last_filing = Filing.where(docket_number: docket_number).last
    days = (Date.today - last_filing.date_received.to_date).to_i
    Scraper.get_filings(docket_number, days)
  end
end
