#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize path
. "$(dirname "$(realpath "$0")")"/../init.sh

echo "* rbenv:    $(rbenv --version)"
echo "* nvm:      $(nvm --version)"
echo "* Ruby:     $(ruby --version)"
echo "* Node.js:  $(node --version)"
echo "* Yarn:     $(yarn --version)"
echo "* Mastodon: $(tootctl version)"
