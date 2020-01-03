# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: `2.6.2`

* System dependencies: `redis-server` for caching

* Configuration: `cp ./config/database.yml.example ./config/database.yml` (although we dont need database, we have to create config file as rails requires)

* Run the test suite: `rspec`

* Services: a `crobjob` (created by `whenever`) is used on production to fetch news list automatically every 5 minutes. See `config/schedule.rb` for more detail

* Deployment instructions: `cap production deploy`