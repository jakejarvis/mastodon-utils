#!/bin/sh

set -e

. $(dirname "$0")/tootctl_shim.sh

tootctl version
