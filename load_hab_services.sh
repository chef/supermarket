#!/bin/bash -e

# This script builds the services from local folder and loads them to habitat studio

# delete the results folder if any
rm -rf results/

# build services
build redis
build nginx
build postgresql
build src/supermarket/habitat-sidekiq
build src/supermarket/habitat-web

## load services
hab svc load chef/supermarket-postgresql
hab svc load chef/supermarket-redis
hab svc load chef/supermarket --bind database:supermarket-postgresql.default --bind redis:supermarket-redis.default
hab svc load chef/supermarket-nginx --bind rails:supermarket.default
hab svc load chef/supermarket-sidekiq --bind redis:supermarket-redis.default --bind database:supermarket-postgresql.default --bind rails:supermarket.default
