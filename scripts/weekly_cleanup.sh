#!/bin/sh

# cronjob ran once per week at 3 AM on Sunday; see https://crontab.guru/#0_3_*_*_0
# syntax for crontab -e:
#   0 3 * * 0  root  /home/mastodon/utils/weekly_cleanup.sh >> /home/mastodon/logs/cron.log 2>&1

set -e

. "$(dirname "$0")/tootctl_shim.sh"

tootctl media remove --days 7
tootctl preview_cards remove --days 90
