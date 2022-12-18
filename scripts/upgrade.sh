#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize path
source "$(dirname "$(realpath "$0")")"/../init.sh

# pull latest mastodon source
cd "$APP_ROOT"
as_mastodon git fetch --all
as_mastodon git stash push --message "pre-upgrade changes"
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ]; then
  # glitch-soc (uses latest commits)
  echo "Pulling latest glitch-soc commits..."
  as_mastodon git checkout glitch-soc/main
else
  # vanilla (uses latest release)
  echo "Pulling latest Mastodon release..."
  as_mastodon git checkout "$(as_mastodon git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)"
fi

# pull & apply latest patches
. "$UTILS_ROOT/scripts/apply_patches.sh"

# create blank custom.css (this overrides any CSS set in the admin panel, but if that's not being used, then
# this quickly saves a request to the backend)
as_mastodon touch "$APP_ROOT/public/custom.css"

# set new ruby version
RUBY_VERSION="$(as_mastodon cat "$APP_ROOT"/.ruby-version)"
as_mastodon RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install "$RUBY_VERSION"
as_mastodon rbenv global "$RUBY_VERSION"

# run migrations:
# https://docs.joinmastodon.org/admin/upgrading/
echo "Running pre-deploy database migrations..."
as_mastodon SKIP_POST_DEPLOYMENT_MIGRATIONS=true RAILS_ENV=production DB_PORT=5432 bundle exec rails db:migrate

# restart mastodon
echo "Restarting services (round 1/2)..."
sudo systemctl restart mastodon-web mastodon-sidekiq mastodon-streaming

# clear caches & run post-deployment db migration
echo "Clearing cache..."
as_mastodon RAILS_ENV=production ruby "$APP_ROOT/bin/tootctl" cache clear
echo "Running post-deploy database migrations..."
as_mastodon RAILS_ENV=production DB_PORT=5432 bundle exec rails db:migrate

# restart mastodon again
echo "Restarting services (round 2/2)..."
sudo systemctl restart mastodon-web mastodon-sidekiq mastodon-streaming

echo "🎉 done!"
