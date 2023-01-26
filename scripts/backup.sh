#!/bin/bash

# cronjob ran every day at 3:15 AM; see https://crontab.guru/#15_3_*_*_*
# syntax for crontab -e:
#   15 3 * * *  bash -c "/home/mastodon/utils/scripts/backup.sh >> /home/mastodon/logs/cron.log 2>&1"

# exit when any step fails
set -euo pipefail

echo -e "\n===== backup.sh: started at $(date '+%Y-%m-%d %H:%M:%S') =====\n"

# initialize paths
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")"/../init.sh

if [ "$(systemctl is-active mastodon-web.service)" = "active" ]; then
  echo "⚠ Mastodon is currently running."
  echo "We'll start the backup anyways, but if it's a critical one, stop all Mastodon"
  echo "services first with 'systemctl stop mastodon-*' and run this again."
  echo ""
fi

# TODO: unsafe & ugly, do better.
TEMP_DIR=$(sudo mktemp -d)
sudo chmod 777 "$TEMP_DIR"

echo "* Backing up Postgres..."
sudo -Hiu postgres pg_dump -Fc mastodon_production -f "$TEMP_DIR/postgres.dump"

echo "* Backing up Redis..."
sudo cp /var/lib/redis/dump.rdb "$TEMP_DIR/redis.rdb"

echo "* Backing up secrets..."
sudo cp "$APP_ROOT/.env.production" "$TEMP_DIR/env.production"

echo "* Backing up certs..."
sudo mkdir -p "$TEMP_DIR/certs"
sudo cp -r /etc/letsencrypt/{archive,live,renewal} "$TEMP_DIR/certs/"

echo "* Compressing..."
TEMP_ARCHIVE="$(sudo mktemp)"
sudo tar --owner=0 --group=0 -czvf "$TEMP_ARCHIVE" -C "$TEMP_DIR" .
sudo mkdir -p "$BACKUPS_ROOT"/{daily,weekly,monthly}
ARCHIVE_FILENAME="mastodon-$(date "+%Y.%m.%d").tar.gz"
# weekly backup (every Sunday)
if [ "$(date +"%u")" -eq 7 ]; then
  WEEKLY_DEST="$BACKUPS_ROOT/weekly/$ARCHIVE_FILENAME"
  sudo cp -f "$TEMP_ARCHIVE" "$WEEKLY_DEST"
  echo "* Saved weekly backup to '$WEEKLY_DEST'"
fi
# monthly backup (first day of the month)
if [ "$(date +"%d")" -eq 1 ]; then
  MONTHLY_DEST="$BACKUPS_ROOT/monthly/$ARCHIVE_FILENAME"
  sudo cp -f "$TEMP_ARCHIVE" "$MONTHLY_DEST"
  echo "* Saved monthly backup to '$MONTHLY_DEST'"
fi
# daily backup (always)
DAILY_DEST="$BACKUPS_ROOT/daily/$ARCHIVE_FILENAME"
sudo cp -f "$TEMP_ARCHIVE" "$DAILY_DEST"
echo "* Saved daily backup to '$DAILY_DEST'"

echo "* Rotating old backups..."
# NOTE: keep all monthly backups for now
# keep last 4 weekly backups
find "$BACKUPS_ROOT/weekly" -mindepth 1 -type f -mtime +3 -delete
# keep last 5 daily backups
find "$BACKUPS_ROOT/daily" -mindepth 1 -type f -mtime +4 -delete

# sync backups dir with s3 bucket if s3cmd is installed & BACKUP_S3_BUCKET env var is set
# https://www.linode.com/docs/products/storage/object-storage/guides/s3cmd/
if [ -n "${BACKUP_S3_BUCKET:+x}" ] && command -v s3cmd >/dev/null 2>&1; then
  echo "* Uploading to S3..."
  sudo s3cmd sync --delete-removed "$BACKUPS_ROOT/" "s3://$BACKUP_S3_BUCKET" || :
else
  echo "⚠ Skipping S3 upload; check that 's3cmd' is installed, and \$BACKUP_S3_BUCKET is set."
fi

echo "* Removing temp files..."
sudo rm -rf --preserve-root "$TEMP_DIR"

echo "* Fixing permissions..."
sudo chown -R "$MASTODON_USER":"$MASTODON_USER" "$BACKUPS_ROOT"

echo "* 🎉 done! (keep this archive safe!)"

echo -e "\n===== backup.sh: finished at $(date '+%Y-%m-%d %H:%M:%S') =====\n"
