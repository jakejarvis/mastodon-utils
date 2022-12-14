#!/bin/bash

# cronjob ran once per week at 3 AM on Sunday; see https://crontab.guru/#0_3_*_*_0
# syntax for crontab -e:
#   0 3 * * 0  bash -c "/home/mastodon/utils/scripts/purge.sh >> /home/mastodon/logs/cron.log 2>&1"

# exit when any step fails
set -o pipefail

echo -e "\n===== purge.sh: started at $(date '+%Y-%m-%d %H:%M:%S') =====\n"

# initialize paths
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")"/../init.sh

tootctl media remove --days 14
tootctl media remove --prune-profiles --days 90
tootctl preview_cards remove --days 90

echo -e "\n===== purge.sh: finished at $(date '+%Y-%m-%d %H:%M:%S') =====\n"
