#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon

if [ ! -d "$MASTODON_ROOT/scripts" ]
then
  # clone repo
  sudo -u mastodon git clone https://github.com/jakejarvis/mastodon-scripts.git "$MASTODON_ROOT/scripts"

  # fix permissions
  sudo chown -R mastodon:mastodon "$MASTODON_ROOT/scripts"
  sudo git config --global --add safe.directory "$MASTODON_ROOT/scripts"
fi

# pull latest patches
cd "$MASTODON_ROOT/scripts"
sudo -u mastodon git pull origin main

# apply custom patches
cd "$MASTODON_ROOT/live"
sudo -u mastodon git apply --allow-binary-replacement --whitespace=warn "$MASTODON_ROOT"/scripts/patches/*.patch || true
