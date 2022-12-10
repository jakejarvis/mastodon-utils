#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon
APP_ROOT="$MASTODON_ROOT/live"
SCRIPTS_ROOT="$MASTODON_ROOT/scripts"
RBENV_ROOT="$MASTODON_ROOT/.rbenv"

# clone this repo if it doesn't exist in the proper location
if [ ! -d "$SCRIPTS_ROOT" ]
then
  sudo -u mastodon git clone https://github.com/jakejarvis/mastodon-scripts.git "$SCRIPTS_ROOT"

  # fix permissions
  sudo chown -R mastodon:mastodon "$SCRIPTS_ROOT"
  sudo git config --global --add safe.directory "$SCRIPTS_ROOT"
fi

# apply custom patches
cd "$APP_ROOT"
sudo -u mastodon git apply --allow-binary-replacement "$SCRIPTS_ROOT"/patches/*.patch
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ];
then
  # apply additional glitch-only patches:
  sudo -u mastodon git apply --allow-binary-replacement "$SCRIPTS_ROOT"/patches/glitch/*.patch
fi

# update dependencies
echo "Updating deps..."
sudo -u mastodon "$RBENV_ROOT/shims/bundle" install --jobs "$(getconf _NPROCESSORS_ONLN)"
sudo -u mastodon yarn install --pure-lockfile --network-timeout 100000

# compile new assets
echo "Compiling new assets..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails assets:precompile
sudo chown -R mastodon:mastodon "$APP_ROOT"

# restart frontend
echo "Restarting mastodon-web..."
sudo systemctl restart mastodon-web
