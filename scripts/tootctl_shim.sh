#!/bin/sh

set -e

MASTODON_ROOT=/home/mastodon

tootctl() {
  ( cd "$MASTODON_ROOT/live" && sudo -u mastodon RAILS_ENV=production "$MASTODON_ROOT/.rbenv/shims/ruby" "$MASTODON_ROOT/live/bin/tootctl" "$@" )
}
