#!/bin/bash
set -euo pipefail

echo "Fixing site url for migration..."

OLD_URL_FILE="/migration/wordpress_files/old-site-url.txt"
NEW_URL="http://localhost:8080"

# Read OLD_URL and trim whitespace/newlines
OLD_URL=$(tr -d '\n' < "$OLD_URL_FILE" | xargs)

# Prevent empty OLD_URL
if [[ -z "$OLD_URL" ]]; then
  echo "Error: OLD_URL is empty. Aborting."
  exit 1
fi

echo "Waiting for WordPress to be ready..."

# Wait until WordPress is installed and ready
until wp core is-installed --allow-root > /dev/null 2>&1; do
  sleep 3
done

echo "Replacing URLs: $OLD_URL -> $NEW_URL"

wp search-replace \
  "$OLD_URL" \
  "$NEW_URL" \
  --all-tables \
  --allow-root

echo "Site url fixing for migration completed successfully"