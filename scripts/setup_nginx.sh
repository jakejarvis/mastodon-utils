#!/bin/bash
# symlinks files from this repo to their proper location

# exit when any step fails
set -euo pipefail

# initialize path
source "$(dirname "$(realpath "$0")")"/../init.sh

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
