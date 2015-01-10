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
                
set :output, "~/ezfs/cron.log"


DOCKETS = %w[
  12-83
  14-261
]

every 1.day do
  DOCKETS.each do |docket_number|
    rbenv_rake "scrape:track docket_number=#{docket_number}"
  end
end
