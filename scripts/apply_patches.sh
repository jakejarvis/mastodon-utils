#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon

if [ ! -d "$MASTODON_ROOT/scripts" ]
then
  sudo -u mastodon git clone https://github.com/jakejarvis/mastodon-scripts.git ./scripts
fi

# pull latest patches
cd "$MASTODON_ROOT/scripts"
sudo -u mastodon git fetch --all
sudo -u mastodon git pull origin main

# apply custom patches
cd "$MASTODON_ROOT/live"
sudo -u mastodon git apply --allow-binary-replacement --whitespace=warn "$MASTODON_ROOT"/mastodon-scripts/patches/*.patch || true
