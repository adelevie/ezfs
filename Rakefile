require './scraper'
require '/.models'

require 'bundler/setup'
require 'yaml'
require 'active_record_migrations'
require 'ecfs'

ActiveRecordMigrations.load_tasks

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

module Test
  def self.docket(docket_number)
    proceeding = ECFS::Proceeding.find(docket_number)
    
    local_count = Filing.where(docket_number: docket_number).count
    fcc_count = proceecing['total_filings'].to_i
    
    if fcc_count == local_count
      STDOUT.puts "Counts match for #{docket_number} (local: #{local_count}, fcc: #{fcc_count})"      
    elsif fcc_count > local_count
      STDOUT.puts "FCC lists more filings for #{docket_number} (local: #{local_count}, fcc: #{fcc_count})"      
    elsif fcc_count < local_count
      STDOUT.puts "Local lists more filings #{docket_number} (local: #{local_count}, fcc: #{fcc_count})"
      STDOUT.puts "This is a huge anomaly. You should investigate."   
    end
  end
  
  def self.all
    Docket.all.each do |docket_number|
      docket(docket_number)
    end
  end
end

namespace :test do
  desc "Compares the total number of filings in the database with the total posted on fcc.gov"
  task :docket do
    docket_number = ENV['docket_number']
    Test.docket(docket_number)
  end
  
  desc "Compares all filings counts with their counts on fcc.gov"
  task :all do
    Test.all
  end
end

namespace :scrape do
  desc "Downloads all filings for a given docket"
  task :all do
    docket_number = ENV['docket_number']
    Scrape.all(docket_number)
  end
  
  desc "Downloads all filings for a given docket with the last n days"
  task :last_n_days do
    docket_number = ENV['docket_number']
    days = ENV['days']
    Scrape.last_n_days(docket_number, days)
  end
  
  desc "Resumes a scrape for a given docket based on the most recent filings already in the database"
  task :resume do
    docket_number = ENV['docket_number']
    Scrape.resume(docket_number)
  end
  
  desc "A meta-task composed of Scrape.all and Scrape.last_n_days to monitor a docket"
  task :track do
    docket_number = ENV['docket_number']
    Scrape.track(docket_number)
  end
end
