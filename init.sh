#!/bin/bash

# default paths
export MASTODON_ROOT=/home/mastodon
export UTILS_ROOT="$MASTODON_ROOT/utils"      # this repository
export APP_ROOT="$MASTODON_ROOT/live"         # actual Mastodon files
export BACKUPS_ROOT="$MASTODON_ROOT/backups"  # backups destination
export LOGS_ROOT="$MASTODON_ROOT/logs"        # logs destintation
export RBENV_ROOT="$MASTODON_ROOT/.rbenv"     # rbenv (w/ ruby-build plugin) directory

# ---

# initialize rbenv manually
if [ -d "$RBENV_ROOT" ]; then
  eval "$($RBENV_ROOT/bin/rbenv init -)"
else
  echo "⚠️ Didn't find rbenv at '$MASTODON_ROOT/.rbenv', double check the paths set in utils/init.sh..."
fi

# check for Mastodon in set location
if [ ! -d "$APP_ROOT" ]; then
  echo "⚠️ Didn't find Mastodon at '$APP_ROOT', double check the paths set in utils/init.sh..."
fi

# clone this repo if it doesn't exist in the proper location
# if [ ! -d "$UTILS_ROOT" ]; then
#   echo "⚠️ Can't find mastodon-utils in '$UTILS_DIR', cloning it for you..."
#   sudo -u mastodon git clone https://github.com/jakejarvis/mastodon-utils.git "$UTILS_ROOT"
# fi

# ---

# run a given command as the 'mastodon' user; e.g. `as_mastodon whoami`
as_mastodon() {
  # don't do unnecessary sudo'ing if we're already mastodon
  if [ "$(whoami)" != "mastodon" ]; then
    sudo -u mastodon env "PATH=$PATH" "$@"
  else
    "$@"
  fi
}

# run /home/mastodon/live/bin/tootctl as 'mastodon' in '/home/mastodon/live'; e.g. `tootctl version`
tootctl() {
  ( cd "$APP_ROOT" && as_mastodon RAILS_ENV=production ruby "$APP_ROOT/bin/tootctl" "$@" )
}
