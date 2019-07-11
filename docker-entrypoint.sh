#!/bin/sh

set -e

echo "Creating database if not yet created..."
bin/rails db:create

echo "Migrating database if any pending migrations..."
bin/rails db:migrate

echo "Updating dependencies if any uninstalled gems..."
bundle install

rm -f tmp/pids/server.pid

exec "$@"
