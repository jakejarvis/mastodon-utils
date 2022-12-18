#!/bin/bash

# cronjob ran once per week at 3 AM on Sunday; see https://crontab.guru/#0_3_*_*_0
# syntax for crontab -e:
#   0 3 * * 0  bash -c "/home/mastodon/utils/scripts/weekly_cleanup.sh >> /home/mastodon/logs/cron.log 2>&1"

# exit when any step fails
set -euo pipefail

# initialize path
source "$(dirname "$(realpath "$0")")"/../init.sh

if [ ! -d "$LOGS_ROOT" ]; then
  as_mastodon mkdir -p "$LOGS_ROOT"
fi

tootctl media remove --days 7
tootctl preview_cards remove --days 90
