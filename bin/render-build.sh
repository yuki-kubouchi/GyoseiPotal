#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Japanese fonts for PDF generation with Prawn
echo "=== Installing Japanese fonts for PDF ==="
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq fonts-ipafont-gothic fonts-ipafont-mincho fonts-ipaexfont
echo "Japanese fonts installed successfully"

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Run seeds to fix production data
bundle exec rails db:seed

# Recalculate invoice amounts after migration
bundle exec rails invoices:recalculate_amounts

echo "=== Setup complete ==="
