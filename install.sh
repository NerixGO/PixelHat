#!/usr/bin/env bash
# PixelHat installer: runs every step from install/ in order.

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

source install/01-check.sh

echo ":: PixelHat is installed."