#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Check if the database exists, create and migrate if not
bundle exec rake db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"