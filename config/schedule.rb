# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# sets rbenv_rake to OS-specific thingy
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

require './models'

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

class Clock
  def initialize(hour, minute, ampm)
    @hour   = hour
    @minute = minute
    @ampm   = ampm
  end
  
  def minute_to_s
    if @minute < 10
      "0#{@minute}"
    else
      @minute
    end
  end
  
  def time_to_s
    "#{@hour}:#{minute_to_s} #{@ampm}"
  end
  
  def inspect
    "<Clock: #{time_to_s} >"
  end
  
  def toggle_ampm!
    if @ampm == 'pm'
      @ampm = 'am'
    else
      @ampm = 'pm'
    end
  end
  
  def add_1_hour!
    if @hour == 12
      toggle_ampm!
    end
    @hour = @hour + 1
  end
  
  def add_1_minute!
    if @minute == 59
      add_1_hour!
      @minute = 0
    else
      @minute = @minute + 1
    end
  end
  
  def add_n_minutes!(n)
    n.times do
      add_1_minute!
    end
  end
end


@clock = Clock.new(6, 0, 'am')

Docket.all.each_slice(5) do |docket_numbers|
  every 1.day, at: @clock.time_to_s do
    docket_numbers.each do |docket_number|
      rbenv_rake "scrape:track docket_number=#{docket_number}"
    end
  end
  
  @clock.add_n_minutes!(5)
end 

# every 1.day, at: '6:00 am' do
#   Docket.all.each do |docket_number|
#     rbenv_rake "scrape:track docket_number=#{docket_number}"
#   end
# end
