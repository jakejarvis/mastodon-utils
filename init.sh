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

# automatically detect glitch-soc
# shellcheck disable=SC2155
export MASTODON_IS_GLITCH=$(test -d "$APP_ROOT/app/javascript/flavours/glitch" && echo true || echo false)

# ---

# initialize rbenv
if [ -s "$RBENV_ROOT/bin/rbenv" ]; then
  eval "$($RBENV_ROOT/bin/rbenv init -)"
else
  echo "⚠️ Couldn't find rbenv in '$RBENV_ROOT', double check the paths set in '$UTILS_ROOT/init.sh'..."
fi

# initialize nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
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
  # crazy bandaids to make sure node & ruby are always available to MASTODON_USER
  # support quotes in args: https://stackoverflow.com/a/68898864/1438024
  CMD=$(
    (
      PS4='+'
      exec 2>&1
      set -x
      true "$@"
    ) | sed 's/^+*true //'
  )
  if [ -s "$RBENV_ROOT/bin/rbenv" ]; then
    CMD="eval \"\$(\"$RBENV_ROOT\"/bin/rbenv init - bash)\"; $CMD"
  fi
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    CMD="source \"$NVM_DIR/nvm.sh\"; $CMD"
  fi

  # don't do unnecessary sudo'ing if we're already MASTODON_USER
  if [ "$(whoami)" != "$MASTODON_USER" ]; then
    sudo -u "$MASTODON_USER" env "PATH=$PATH" "NVM_DIR=$NVM_DIR" "RBENV_ROOT=$RBENV_ROOT" bash -c "$CMD"
  else
    bash -c "$CMD"
  fi
}

# run 'bin/tootctl' as MASTODON_USER in APP_ROOT from anywhere (`tootctl version`)
tootctl() {
  ( cd "$APP_ROOT" && as_mastodon RAILS_ENV=production ruby ./bin/tootctl "$@" )
}

# ---

# keep track of whether this file has already been run
export MASTODON_INIT_RUN=1
