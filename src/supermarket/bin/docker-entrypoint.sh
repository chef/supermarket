#!/bin/bash
set -e

# Set up the database (safe to run repeatedly)
bundle exec rake db:create 2>/dev/null || true
bundle exec rake db:schema:load db:migrate

# Hand off to whatever command was passed (rails server, rake spec, etc.)
exec "$@"
