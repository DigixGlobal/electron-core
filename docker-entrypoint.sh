#!/bin/sh
set -e

echo "Creating database if it's not present..."
bin/rails db:create

echo "Migrating database..."
bin/rails db:migrate

if ! bundle check; then
    echo "Updating dependencies..."
    bundle install
fi

rm -f tmp/pids/server.pid

exec "$@"
