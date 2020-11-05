#!/usr/bin/env bash
# Delete a store directory
set -euo pipefail

find "$1" -exec chmod +w {} \;
rm -rf "$1"
