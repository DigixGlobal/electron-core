#!/bin/sh

set -e

echo "Updating dependencies if any uninstalled gems..."
bundle check || bundle install

echo "Creating database if not yet created..."
bin/rails db:create

echo "Migrating database if any pending migrations..."
bin/rails db:migrate

rm -f tmp/pids/server.pid

echo "Clearing cache..."
spring stop

exec "$@"
