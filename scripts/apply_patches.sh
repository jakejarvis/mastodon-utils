#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize path
. "$(dirname "$(realpath "$0")")"/../init.sh

# apply custom patches
cd "$APP_ROOT"
as_mastodon git apply --reject --allow-binary-replacement "$UTILS_ROOT"/patches/*.patch
if [ -d "$APP_ROOT/app/javascript/flavours/glitch" ]; then
  # apply additional glitch-only patches:
  as_mastodon git apply --reject --allow-binary-replacement "$UTILS_ROOT"/patches/glitch/*.patch
fi

# compile new assets
echo "Compiling new assets..."
as_mastodon RAILS_ENV=production bundle exec rails assets:precompile

# optional: create blank custom.css (this overrides any CSS set in the admin panel, but if that's not being used, then
# this is an easy way to save a request to the backend)
as_mastodon touch "$APP_ROOT/public/custom.css"
