#!/bin/bash

# exit when any step fails
set -euo pipefail

# :)
MY_NAME_IS_JAKE_JARVIS="false"

# can't say you weren't warned
if [ "$MY_NAME_IS_JAKE_JARVIS" != "pinky promise" ]; then
  echo "🚨 LISTEN UP!!!! YOU PROBABLY WANT THIS SCRIPT INSTEAD:"
  echo "https://github.com/jakejarvis/mastodon-installer/blob/main/upgrade.sh"
  exit 69
fi

# initialize paths
. "$(dirname "${BASH_SOURCE[0]}")"/../init.sh

# pull latest mastodon source
cd "$APP_ROOT"
as_mastodon git fetch --all
as_mastodon git stash push --include-untracked --message "pre-upgrade changes"
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ]; then
  # glitch-soc (uses latest commits)
  echo "Pulling latest glitch-soc commits..."
  as_mastodon git checkout glitch-soc/main
else
  # vanilla (uses latest release)
  echo "Pulling latest Mastodon release..."
  as_mastodon git checkout "$(as_mastodon git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)"
fi

# re-apply customizations
. "$UTILS_ROOT"/scripts/customize.sh

# set new ruby version
as_mastodon RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install --skip-existing
as_mastodon rbenv global "$(as_mastodon cat "$APP_ROOT"/.ruby-version)"

# set new node version
as_mastodon nvm install
as_mastodon nvm use
as_mastodon npm install --global yarn

# update dependencies
as_mastodon bundle install --jobs "$(getconf _NPROCESSORS_ONLN)"
as_mastodon yarn install --pure-lockfile

# compile new assets
echo "Compiling new assets..."
as_mastodon RAILS_ENV=production bundle exec rails assets:precompile

# run migrations:
# https://docs.joinmastodon.org/admin/upgrading/
echo "Running pre-deploy database migrations..."
# note: DB_PORT is hard-coded because we need the raw DB, and .env.production might be pointing at pgbouncer
as_mastodon DB_PORT=5432 SKIP_POST_DEPLOYMENT_MIGRATIONS=true RAILS_ENV=production bundle exec rails db:migrate

# restart mastodon
echo "Restarting services (round 1/2)..."
sudo systemctl restart mastodon-web mastodon-sidekiq mastodon-streaming

# clear caches & run post-deployment db migration
echo "Clearing cache..."
as_mastodon RAILS_ENV=production ruby "$APP_ROOT/bin/tootctl" cache clear
echo "Running post-deploy database migrations..."
# note: DB_PORT is hard-coded because we need the raw DB, and .env.production might be pointing at pgbouncer
as_mastodon DB_PORT=5432 RAILS_ENV=production bundle exec rails db:migrate

# restart mastodon again
echo "Restarting services (round 2/2)..."
sudo systemctl restart mastodon-web mastodon-sidekiq mastodon-streaming

echo "🎉 done!"
