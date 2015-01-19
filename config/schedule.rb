require './models'
require './clock'
require './os'

if OS.linux?
  user = "alan" # change this to your Ubuntu user
  job_type :rbenv_rake, %Q{export PATH=/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
                           cd :path && bundle exec rake :task --silent :output }
elsif OS.mac?
  job_type :rbenv_rake, %Q{export PATH=/opt/rbenv/shims:/opt/rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
                           cd :path && bundle exec rake :task --silent :output }
end
                
set :output, "~/ezfs/log/cron.log"

@clock = Clock.new(12, 0, 'am')

CONCURRENT_SCRAPES = 2

Docket.all.each_slice(CONCURRENT_SCRAPES) do |docket_numbers|
  every :weekday, at: @clock.time_to_s do
    docket_numbers.each do |docket_number|
      rbenv_rake "scrape:track docket_number=#{docket_number}"
    end
  end
  
  @clock.add_n_minutes!(20)
end 
