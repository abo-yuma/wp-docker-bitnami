#!/bin/bash

# Exit immediately if:
# - any command fails (-e)
# - undefined variable is used (-u)
# - any command in a pipeline fails (pipefail)
set -euo pipefail

# Path to live WordPress wp-content directory (inside container)
WP_CONTENT_PATH="/bitnami/wordpress/wp-content"

# Path to migration source files (mounted volume)
MIGRATION_PATH="/migration/wordpress_files"

echo "Start wp-content migration (replace mode)"

# Function to fully replace a wp-content subdirectory
# Arguments:
#   $1 = target directory (destination)
#   $2 = source directory (migration files)
#   $3 = label name (for logging)
migrate_wp_content () {
  local TARGET_DIR="$1"
  local SOURCE_DIR="$2"
  local NAME="$3"

  echo "[$NAME]"

  # Skip if source directory does not exist
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source not found, skipping: $SOURCE_DIR"
    return
  fi

  echo "Replacing $TARGET_DIR with $SOURCE_DIR"

  # Safety guard to prevent catastrophic deletion
  # (e.g., if TARGET_DIR is empty or root "/")
  if [[ -z "$TARGET_DIR" || "$TARGET_DIR" == "/" ]]; then
    echo "Invalid TARGET_DIR, aborting"
    exit 1
  fi

  # Remove the entire target directory (clean replace strategy)
  rm -rf "$TARGET_DIR"

  # Recreate empty directory before copying
  mkdir -p "$TARGET_DIR"

  echo "Copying..."

  # Copy files using tar stream
  # This preserves structure and is faster than cp for large directories
  tar cf - -C "$SOURCE_DIR" . | tar xf - -C "$TARGET_DIR"

  echo "Copy done"

  # Fix ownership if running as root (Bitnami uses UID 1001)
  if [ "$(id -u)" = "0" ]; then
    echo "Fixing permissions..."

    # Change ownership only for files not already owned by 1001
    find "$TARGET_DIR" \! -user 1001 -exec chown 1001:1001 {} +
  fi
}

# Migrate each wp-content subdirectory
migrate_wp_content "$WP_CONTENT_PATH/themes" "$MIGRATION_PATH/themes" "themes"
migrate_wp_content "$WP_CONTENT_PATH/plugins" "$MIGRATION_PATH/plugins" "plugins"
migrate_wp_content "$WP_CONTENT_PATH/uploads" "$MIGRATION_PATH/uploads" "uploads"

echo "Migration process completed"