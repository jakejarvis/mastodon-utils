#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize paths
# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")"/../init.sh

echo "* rbenv:    $(rbenv --version)"
echo "* nvm:      $(nvm --version)"
echo "* Ruby:     $(ruby --version)"
echo "* Node.js:  $(node --version)"
echo "* Yarn:     $(yarn --version)"
echo "* Mastodon: $(tootctl version)"
