#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize paths
. "$(dirname "${BASH_SOURCE[0]}")"/../init.sh

# re-detect glitch-soc
MASTODON_IS_GLITCH="$(test -d "$APP_ROOT/app/javascript/flavours/glitch" && echo true || echo false)"

# ---

# apply custom patches (skips errors)
for f in "$UTILS_ROOT"/patches/*.patch; do
  as_mastodon git apply --reject --allow-binary-replacement "$f" || :
done

# apply additional glitch-only patches if applicable
if [ "$MASTODON_IS_GLITCH" = true ]; then
  for f in "$UTILS_ROOT"/patches/glitch/*.patch; do
    as_mastodon git apply --reject --allow-binary-replacement "$f" || :
  done
fi

# ---

# remove this list of unused glitch cruft
if [ "$MASTODON_IS_GLITCH" = true ]; then
  removePaths=(
    "app/javascript/images/clippy_frame.png"
    "app/javascript/images/clippy_wave.gif"
    "app/javascript/images/icon_*.png"
    "app/javascript/images/start.png"
    "app/javascript/skins/vanilla/win95/"
    "app/javascript/styles/win95.scss"
    "public/background-cybre.png"
    "public/clock.js"
    "public/logo-cybre-glitch.gif"
    "public/riot-glitch.png"
  )

  for f in "${removePaths[@]}"; do
    as_mastodon rm -rf --preserve-root "$APP_ROOT/$f"
  done
fi

# ---

# apply a more restrictive robots.txt
as_mastodon tee "$APP_ROOT/public/robots.txt" > /dev/null <<EOT
# block everything except About page
User-agent: *
Allow: /about
Disallow: /

# sorry, Elon :)
User-agent: Twitterbot
Disallow: /
EOT

# ---

# change default settings, mostly for logged-out visitors
# requires yq (`snap install yq` - it's like jq but for yaml: https://github.com/mikefarah/yq/#install)
if command -v yq >/dev/null 2>&1; then
  as_mastodon yq -i '.defaults.site_title = "Mastodon"' "$APP_ROOT/config/settings.yml"
  as_mastodon yq -i '.defaults.show_application = true' "$APP_ROOT/config/settings.yml"
fi

# ---

# change glitch-only settings located in a JS file, also mostly for logged-out visitors
if [ "$MASTODON_IS_GLITCH" = true ]; then
  set_default() {
    as_mastodon sed \
      -i "$APP_ROOT/app/javascript/flavours/glitch/reducers/local_settings.js" \
      -e "s/$1\s*:\s*.*/$1: $2, \/\/ updated by customize.sh/g" || :
  }

  set_default "show_reply_count" "true"
  set_default "hicolor_privacy_icons" "true"
  set_default "rewrite_mentions" "'acct'"
  set_default "lengthy" "false"
  set_default "letterbox" "false"
  set_default "language" "false"
fi

# ---

# create a blank 'custom.css' to save a request to the backend, assuming it's not being used
as_mastodon touch "$APP_ROOT/public/custom.css"
