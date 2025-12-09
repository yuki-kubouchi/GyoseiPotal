#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Recalculate invoice amounts after migration
# This ensures all invoices have their amounts properly calculated and stored
bundle exec rails invoices:recalculate_amounts

echo "=== Checking production data ==="
bundle exec rails production:check_data

echo "=== Fixing production data ==="
bundle exec rails production:fix_data
