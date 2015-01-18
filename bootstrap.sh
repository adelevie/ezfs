git pull origin master
bundle

if [ ! -f db/config.yml ]; then
  cp db/config.yml.sample db/config.yml
fi

if [ ! -f scraper.log ]; then
  touch log/scraper.log
fi

if [ ! -f db/cron.log ]; then
  touch log/cron.log
fi

if ! gem spec whenever > /dev/null 2>&1; then
  gem install whenever
fi

echo "Bootstrapping complete."
echo "To edit the cron schedule, type:"
echo "nano config/schedule.rb"
echo "And then type:"
echo "whenever -i"
