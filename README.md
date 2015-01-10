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

## Installation

Clone the repo and `cd` into it.

```sh
$ bundle
$ bundle exec rake db:migrate
$ cp db/config.yml.sample db/config.yml
```

### Databases

Uses `sqlite` for `development` and `postgres` for `production`. The default mode is `development`, but you can change `EZFS_ENV` to `production` on your server.

## Deployment

(tested on a Digital Ocean, Ubunutu 14 box)

Dependencies:

- `rbenv`
- `sudo apt-get install libpq-dev` (for Ubuntu)

```sh
git clone https://github.com/adelevie/ezfs.git
cd ezfs
touch cron.log
nano db/config.yml # add your own postgres db config
bundle install --without development
nano config/schedule.rb # edit the cron schedule
bundle exec whenever --update-crontab
tail -f cron.log # and watch the scraping happen
```
