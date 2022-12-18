#!/bin/bash

# exit when any step fails
set -euo pipefail

# initialize path
. "$(dirname "$(realpath "$0")")"/../init.sh

echo "* rbenv version: $(rbenv --version)"
echo "* Ruby version: $(ruby --version)"
echo "* Mastodon version: $(tootctl version)"
