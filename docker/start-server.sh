#! /bin/sh

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup

exec "$@"
