#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon

if [ "$(systemctl is-active mastodon-web.service)" = "active" ]
then
  echo "⚠️  Mastodon is currently running."
  echo "We'll start the backup anyways, but if it's a critical one, stop all Mastodon"
  echo "services first with 'systemctl stop mastodon-*' and run this again."
  echo ""
fi

if [ ! -d "$MASTODON_ROOT/backups" ]
then
  sudo mkdir -p "$MASTODON_ROOT/backups"
  sudo chown -R mastodon:mastodon "$MASTODON_ROOT/backups"
fi

TEMP_DIR=$(sudo -u mastodon mktemp -d)

echo "Backing up Postgres..."
sudo -u mastodon pg_dump -Fc mastodon_production -f "$TEMP_DIR/postgres.dump"

echo "Backing up Redis..."
sudo cp /var/lib/redis/dump.rdb "$TEMP_DIR/redis.rdb"

echo "Backing up secrets..."
sudo cp "$MASTODON_ROOT/live/.env.production" "$TEMP_DIR/env.production"

echo "Compressing..."
ARCHIVE_DEST="$MASTODON_ROOT/backups/$(date "+%Y.%m.%d-%H.%M.%S").tar.gz"
sudo tar --owner=0 --group=0 -czvf "$ARCHIVE_DEST" -C "$TEMP_DIR" .
sudo chown mastodon:mastodon "$ARCHIVE_DEST"

sudo rm -rf --preserve-root "$TEMP_DIR"

echo "Saved to $ARCHIVE_DEST"
echo "🎉 done! (keep this archive safe!)"
