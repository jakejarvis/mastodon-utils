#!/bin/bash

# load custom environment variables
MASTODON_ENV_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.env"
if [ -s "$MASTODON_ENV_PATH" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$MASTODON_ENV_PATH"
  set +a
else
  echo "⚠ Missing .env file at '$MASTODON_ENV_PATH'. Falling back to defaults from '$MASTODON_ENV_PATH.example'."
fi

# fall back to default env variables & re-export them
export MASTODON_USER="${MASTODON_USER:="mastodon"}"
export MASTODON_ROOT="${MASTODON_ROOT:="/home/$MASTODON_USER"}"
export UTILS_ROOT="${UTILS_ROOT:="$MASTODON_ROOT/utils"}"
export APP_ROOT="${APP_ROOT:="$MASTODON_ROOT/live"}"
export BACKUPS_ROOT="${BACKUPS_ROOT:="$MASTODON_ROOT/backups"}"
export LOGS_ROOT="${LOGS_ROOT:="$MASTODON_ROOT/logs"}"
export RBENV_ROOT="${RBENV_ROOT:="$MASTODON_ROOT/.rbenv"}"
export NVM_DIR="${NVM_DIR:="$MASTODON_ROOT/.nvm"}"

# automatically detect glitch-soc
# shellcheck disable=SC2155
export MASTODON_IS_GLITCH=$(test -d "$APP_ROOT/app/javascript/flavours/glitch" && echo true || echo false)

# ---

# initialize rbenv
if [ -s "$RBENV_ROOT/bin/rbenv" ]; then
  eval "$("$RBENV_ROOT"/bin/rbenv init -)"
else
  echo "⚠ rbenv wasn't found in '$RBENV_ROOT'. You might need to override RBENV_ROOT in '$MASTODON_ENV_PATH'..."
fi

# initialize nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
else
  echo "⚠ nvm wasn't found in '$NVM_DIR'. You might need to override NVM_DIR in '$MASTODON_ENV_PATH'..."
fi

# check for Mastodon in set location
if [ ! -d "$APP_ROOT" ]; then
  echo "⚠ Mastodon wasn't found at '$APP_ROOT'. You might need to override APP_ROOT in '$MASTODON_ENV_PATH'..."
fi

# clone this repo if it doesn't exist in the proper location
# if [ ! -d "$UTILS_ROOT" ]; then
#   echo "⚠ mastodon-utils wasn't found in '$UTILS_ROOT'. Cloning it for you..."
#   as_mastodon git clone https://github.com/jakejarvis/mastodon-utils.git "$UTILS_ROOT"
# fi

# ---

# run a given command as MASTODON_USER (`as_mastodon whoami`)
as_mastodon() {
  # support quotes in args: https://stackoverflow.com/a/68898864/1438024
  # shellcheck disable=SC2155
  local CMD=$(
    (
      PS4='+'
      exec 2>&1
      set -x
      true "$@"
    ) | sed 's/^+*true //'
  )

  # crazy bandaids to make sure ruby & node are always available to MASTODON_USER
  if [ -s "$RBENV_ROOT/bin/rbenv" ]; then
    # prepend rbenv setup script to given command
    CMD="eval \"\$(\"$RBENV_ROOT\"/bin/rbenv init - bash)\"; $CMD"
  fi
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # prepend nvm setup script to given command
    CMD="source \"$NVM_DIR/nvm.sh\"; $CMD"
  fi

  # don't do unnecessary sudo'ing if we're already MASTODON_USER
  if [ "$(whoami)" != "$MASTODON_USER" ]; then
    sudo -u "$MASTODON_USER" env "PATH=$PATH" "NVM_DIR=$NVM_DIR" "RBENV_ROOT=$RBENV_ROOT" bash -c "$CMD"
  else
    bash -c "$CMD"
  fi
}

# run 'bin/tootctl' as $MASTODON_USER in $APP_ROOT from anywhere (`tootctl version`)
tootctl() {
  # native tootctl *must* be run while in the mastodon source directory
  if [ -d "$APP_ROOT" ]; then
    (cd "$APP_ROOT" && as_mastodon RAILS_ENV=production ruby ./bin/tootctl "$@")
  else
    echo "⚠ Can't run tootctl because Mastodon wasn't found at '$APP_ROOT'. You might need to override APP_ROOT in '$MASTODON_ENV_PATH'..."
    return 1
  fi
}

# ---

# keep track of whether this file has already been run
export MASTODON_INIT_RUN=1
