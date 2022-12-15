#!/bin/sh

MASTODON_ROOT=/home/mastodon
APP_ROOT="$MASTODON_ROOT/live"
RBENV_ROOT="$MASTODON_ROOT/.rbenv"

tootctl() {
  ( cd "$APP_ROOT" && sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/ruby" "$APP_ROOT/bin/tootctl" "$@" )
}
