#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Japanese fonts for PDF generation with Prawn
echo "=== Installing Japanese fonts for PDF ==="
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq fonts-ipafont-gothic fonts-ipafont-mincho fonts-ipaexfont
echo "Japanese fonts installed successfully"

# Verify font installation
echo "=== Verifying font installation ==="
find /usr/share/fonts -name "*.ttf" -o -name "*.otf" | grep -i ipa || echo "Warning: IPA fonts not found in expected location"
ls -la /usr/share/fonts/truetype/ipafont* || echo "Font directory not found at expected path"
echo "=== Font verification complete ==="

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

echo "=== Build complete (database tasks will run on app startup) ==="
