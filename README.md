# EZFS

Makes ECFS easier.

## What's included?

So far, this is just a set of scripts that scrapes ECFS data and loads it into a database.

## Usage

Scrape all filings for a given docket:

```sh
$ bundle exec rake scrape:all docket_number=12-83
```

Scrape all filings from the last _n_ days:

```sh
$ bundle exec rake scrape:last_n_days docket_number=12-83 days=1
```

Resume a scrape (these things take a while and are prone to interruptions):

```sh
$ bundle exec rake scrape:resume docket_number=12-83
```

Track a docket over time (good for running once every `n` days with `cron` or the `whenever` gem):

```sh
$ bundle exec rake scrape:track docket_number=12-83
```

Inspect data with a `pry` console:

```sh
$ ruby console.rb
```

## Installation/deployment

(tested on a Digital Ocean, Ubunutu 14 box)

Dependencies:

- `rbenv`
- `sudo apt-get install libpq-dev` (for Ubuntu)


```sh
git clone https://github.com/adelevie/ezfs.git
cd ezfs
cp db/config.yml.sample db/config.yml
nano db/config.yml
bundle install --without development
bundle exec rake db:migrate db=production
touch log/cron.log
touch log/scraper.log
nano config/schedule.rb
bundle exec whenever --update-crontab
source .env
nano .env
./restart.sh # serves the site at localhost:4567
```

Works really great with [nginx-ssl](https://github.com/vzvenyach/nginx-ssl):

```
sudo bash bootstrap.sh -d -p 4567 -s test.example.com
```

