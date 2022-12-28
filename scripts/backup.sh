#!/bin/bash

# cronjob ran every day at 3:15 AM; see https://crontab.guru/#15_3_*_*_*
# syntax for crontab -e:
#   15 3 * * *  bash -c "/home/mastodon/utils/scripts/backup.sh >> /home/mastodon/logs/cron.log 2>&1"

# exit when any step fails
set -euo pipefail

echo -e "\n===== backup.sh: started at $(date '+%Y-%m-%d %H:%M:%S') =====\n"

# initialize path
. "$(dirname "$(realpath "$0")")"/../init.sh

if [ "$(systemctl is-active mastodon-web.service)" = "active" ]; then
  echo "⚠️  Mastodon is currently running."
  echo "We'll start the backup anyways, but if it's a critical one, stop all Mastodon"
  echo "services first with 'systemctl stop mastodon-*' and run this again."
  echo ""
fi

if [ ! -d "$BACKUPS_ROOT" ]; then
  as_mastodon mkdir -p "$BACKUPS_ROOT"
fi

if [ ! -d "$LOGS_ROOT" ]; then
  as_mastodon mkdir -p "$LOGS_ROOT"
fi

TEMP_DIR=$(as_mastodon mktemp -d)

echo "Backing up Postgres..."
as_mastodon pg_dump -Fc mastodon_production -f "$TEMP_DIR/postgres.dump"

echo "Backing up Redis..."
sudo cp /var/lib/redis/dump.rdb "$TEMP_DIR/redis.rdb"

echo "Backing up secrets..."
sudo cp "$APP_ROOT/.env.production" "$TEMP_DIR/env.production"

echo "Backing up certs..."
sudo mkdir -p "$TEMP_DIR/certs"
sudo cp -r /etc/letsencrypt/{archive,live,renewal} "$TEMP_DIR/certs/"

echo "Compressing..."
ARCHIVE_DEST="$BACKUPS_ROOT/mastodon-$(date "+%Y.%m.%d-%H.%M.%S").tar.gz"
sudo tar --owner=0 --group=0 -czvf "$ARCHIVE_DEST" -C "$TEMP_DIR" .
sudo chown "$MASTODON_USER":"$MASTODON_USER" "$ARCHIVE_DEST"

echo "Removing temp files..."
sudo rm -rf --preserve-root "$TEMP_DIR"

echo "Saved to $ARCHIVE_DEST"

if command -v linode-cli >/dev/null 2>&1; then
  echo "Uploading to S3..."
  sudo linode-cli obj put "$ARCHIVE_DEST" jarvis-backup
fi

echo "🎉 done! (keep this archive safe!)"

echo -e "\n===== backup.sh: finished at $(date '+%Y-%m-%d %H:%M:%S') =====\n"
