#!/bin/bash

# user running mastodon
export MASTODON_USER=mastodon

# default paths
export MASTODON_ROOT="/home/$MASTODON_USER"   # home dir of the user above
export UTILS_ROOT="$MASTODON_ROOT/utils"      # this repository
export APP_ROOT="$MASTODON_ROOT/live"         # actual Mastodon files
export BACKUPS_ROOT="$MASTODON_ROOT/backups"  # backups destination
export LOGS_ROOT="$MASTODON_ROOT/logs"        # logs destintation
export RBENV_ROOT="$MASTODON_ROOT/.rbenv"     # rbenv (w/ ruby-build plugin) directory
export NVM_DIR="$MASTODON_ROOT/.nvm"          # nvm directory

# ---

# initialize rbenv
if [ -s "$RBENV_ROOT/bin/rbenv" ]; then
  eval "$($RBENV_ROOT/bin/rbenv init -)"
else
  echo "⚠️ Couldn't find rbenv in '$RBENV_ROOT', double check the paths set in '$UTILS_ROOT/init.sh'..."
fi

# initialize nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
else
  echo "⚠️ Couldn't find nvm.sh in '$NVM_DIR', double check the paths set in '$UTILS_ROOT/init.sh'..."
fi

# check for Mastodon in set location
if [ ! -d "$APP_ROOT" ]; then
  echo "⚠️ Couldn't find Mastodon at '$APP_ROOT', double check the paths set in '$UTILS_ROOT/init.sh'..."
fi

# clone this repo if it doesn't exist in the proper location
# if [ ! -d "$UTILS_ROOT" ]; then
#   echo "⚠️ Couldn't find mastodon-utils at '$UTILS_ROOT', cloning it for you..."
#   as_mastodon git clone https://github.com/jakejarvis/mastodon-utils.git "$UTILS_ROOT"
# fi

# ---

# run a given command as MASTODON_USER (`as_mastodon whoami`)
as_mastodon() {
  # don't do unnecessary sudo'ing if we're already mastodon
  if [ "$(whoami)" != "$MASTODON_USER" ]; then
    sudo -u "$MASTODON_USER" env "PATH=$PATH" "$@"
  else
    "$@"
  fi
}

# run 'bin/tootctl' as MASTODON_USER in APP_ROOT from anywhere (`tootctl version`)
tootctl() {
  ( cd "$APP_ROOT" && as_mastodon RAILS_ENV=production ruby "$APP_ROOT/bin/tootctl" "$@" )
}
