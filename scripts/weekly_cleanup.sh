#!/bin/sh

# cronjob ran once per week at 3 AM on Sunday; see https://crontab.guru/#0_3_*_*_0
# syntax for crontab -e:
#   0 3 * * 0  root  /home/mastodon/scripts/weekly_cleanup.sh >> /home/mastodon/logs/cron.log 2>&1

set -e

. $(dirname "$0")/toot_shim.sh

tootctl media remove --days 7
tootctl preview_cards remove --days 90

curl -X GET 'https://betteruptime.com/api/v1/heartbeat/EZYUHRmbatzh4tBfTvzX22go'
