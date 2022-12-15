#!/bin/bash
# symlinks files from this repo to their proper location

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon
APP_ROOT="$MASTODON_ROOT/live"
UTILS_ROOT="$MASTODON_ROOT/utils"

# clone this repo if it doesn't exist in the proper location
if [ ! -d "$UTILS_ROOT" ]
then
  sudo -u mastodon git clone https://github.com/jakejarvis/mastodon-utils.git "$UTILS_ROOT"

  # fix permissions
  sudo chown -R mastodon:mastodon "$UTILS_ROOT"
  sudo git config --global --add safe.directory "$UTILS_ROOT"
fi

# setup nginx config
sudo rm -rf /etc/nginx/sites-available
sudo rm -rf /etc/nginx/sites-enabled/*
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo ln -sf "$UTILS_ROOT/etc/nginx/nginx.conf" /etc/nginx/nginx.conf
sudo ln -sf "$UTILS_ROOT/etc/nginx/modules" /usr/lib/nginx/modules
sudo ln -sf "$UTILS_ROOT/etc/nginx/sites-available" /etc/nginx/sites-available
sudo ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
sudo ln -sf /etc/nginx/sites-available/mastodon.conf /etc/nginx/sites-enabled/mastodon.conf
sudo nginx -t
sudo nginx -s reload
