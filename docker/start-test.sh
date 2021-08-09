#! /bin/sh

bundle exec rake db:test:prepare

exec "$@"
