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

# from http://benscheirman.com/2013/12/using-rbenv-in-cron-jobs/
#job_type :rbenv_rake, %Q{export PATH=/opt/rbenv/shims:/opt/rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
#                         cd :path && bundle exec rake :task --silent :output }

                

set :output, "~/ezfs/cron.log"

job_type :rbenv_rake, "source ~/.bashrc && cd :path && bundle exec rake :task --silent :output"

every 1.minute do
  rbenv_rake "scrape:last_n_days docket_number=14-28 days=2"
end
