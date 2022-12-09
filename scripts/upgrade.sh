#!/bin/bash

# exit when any step fails
set -euo pipefail

# default paths
MASTODON_ROOT=/home/mastodon
APP_ROOT="$MASTODON_ROOT/live"
RBENV_ROOT="$MASTODON_ROOT/.rbenv"

# check for existing installation
if [ ! -d "$APP_ROOT" ]; then
  echo "$APP_ROOT doesn't exist, are you sure Mastodon is installed?"
  exit 255
fi

# pull latest mastodon source
cd "$APP_ROOT"
sudo -u mastodon git fetch --all
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ]; then
  # glitch-soc (uses latest commits)
  echo "Pulling latest glitch-soc commits..."
  sudo -u mastodon git checkout glitch-soc/main
else
  # vanilla (uses latest release)
  echo "Pulling latest Mastodon release..."
  sudo -u mastodon git checkout "$(sudo -u mastodon git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)"
fi

# pull & apply latest patches
. "$(dirname "$0")/apply_patches.sh"

# set new ruby version
RUBY_VERSION="$(sudo -u mastodon cat $APP_ROOT/.ruby-version)"
sudo -u mastodon RUBY_CONFIGURE_OPTS=--with-jemalloc "$RBENV_ROOT/bin/rbenv" install "$RUBY_VERSION" || true
sudo -u mastodon "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION"

# run migrations:
# https://docs.joinmastodon.org/admin/upgrading/
echo "Running pre-deploy database migrations..."
sudo -u mastodon SKIP_POST_DEPLOYMENT_MIGRATIONS=true RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails db:migrate

# restart mastodon
echo "Restarting services (round 1/2)..."
sudo systemctl restart mastodon-sidekiq mastodon-streaming

# clear caches & run post-deployment db migration
echo "Clearing cache..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/ruby" "$APP_ROOT/bin/tootctl" cache clear
echo "Running post-deploy database migrations..."
sudo -u mastodon RAILS_ENV=production "$RBENV_ROOT/shims/bundle" exec rails db:migrate

# restart mastodon again
echo "Restarting services (round 2/2)..."
sudo systemctl restart mastodon-web mastodon-sidekiq mastodon-streaming

echo "🎉 done!"