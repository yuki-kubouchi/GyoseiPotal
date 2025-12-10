#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Japanese fonts for PDF generation
echo "=== Installing Japanese fonts ==="
if command -v apt-get &> /dev/null; then
  apt-get update -qq
  apt-get install -y -qq fonts-ipafont-gothic fonts-ipafont-mincho
  echo "Japanese fonts installed successfully"
else
  echo "apt-get not available, skipping font installation"
fi

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Run seeds to fix production data
bundle exec rails db:seed

# Recalculate invoice amounts after migration
# This ensures all invoices have their amounts properly calculated and stored
bundle exec rails invoices:recalculate_amounts

echo "=== Diagnosing PDF data issue ==="
bundle exec rails production:diagnose_pdf
