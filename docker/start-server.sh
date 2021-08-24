#! /bin/sh

echo "DB migration: started"
rake db:migrate
echo "DB migration: done"

echo "CMD:"
echo "$@"

exec "$@"
