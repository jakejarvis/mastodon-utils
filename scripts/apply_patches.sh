#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize path
source "$(dirname "$(realpath "$0")")"/../init.sh

# apply custom patches
cd "$APP_ROOT"
as_mastodon git apply --reject --allow-binary-replacement "$UTILS_ROOT"/patches/*.patch
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ]; then
  # apply additional glitch-only patches:
  as_mastodon git apply --reject --allow-binary-replacement "$UTILS_ROOT"/patches/glitch/*.patch
fi

# update dependencies
echo "Updating deps..."
as_mastodon bundle install --jobs "$(getconf _NPROCESSORS_ONLN)"
as_mastodon yarn install --pure-lockfile --network-timeout 100000

# compile new assets
echo "Compiling new assets..."
as_mastodon RAILS_ENV=production bundle exec rails assets:precompile

# restart frontend
echo "Restarting mastodon-web..."
sudo systemctl restart mastodon-web
