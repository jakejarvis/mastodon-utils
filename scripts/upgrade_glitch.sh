#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon
RBENV_ROOT="$MASTODON_ROOT/.rbenv"

# check for existing installation
if [ ! -d "$MASTODON_ROOT/live" ]
then
  echo "$MASTODON_ROOT/live doesn't exist, are you sure Mastodon is installed?"
  exit 255
fi

# pull latest mastodon source
cd "$MASTODON_ROOT/live"
sudo -u mastodon git fetch --all
sudo -u mastodon git checkout glitch-soc/main
sudo -u mastodon git pull glitch-soc main

# pull & apply latest patches
. $(dirname "$0")/apply_patches.sh

# update dependencies
echo "Updating deps..."
sudo -u mastodon "$RBENV_ROOT/shims/bundle" install --jobs "$(getconf _NPROCESSORS_ONLN)"
sudo -u mastodon yarn install --pure-lockfile --network-timeout 100000

# run migrations:
# https://docs.joinmastodon.org/admin/upgrading/
echo "Running pre-deploy database migrations..."
sudo -u mastodon SKIP_POST_DEPLOYMENT_MIGRATIONS=true RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails db:migrate
echo "Compiling new assets..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails assets:precompile

# restart mastodon
echo "Restarting services (round 1/2)..."
sudo systemctl reload mastodon-web
sudo systemctl restart mastodon-sidekiq mastodon-streaming

# clear caches & run post-deployment db migration
echo "Clearing cache..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/ruby" "$MASTODON_ROOT/live/bin/tootctl" cache clear
echo "Running post-deploy database migrations..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails db:migrate

# restart mastodon again
echo "Restarting services (round 2/2)..."
sudo systemctl reload mastodon-web
sudo systemctl restart mastodon-sidekiq mastodon-streaming

echo "🎉 done!"
