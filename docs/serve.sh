#!/usr/bin/env bash
# Build and serve the docs for local development
set -euo pipefail
webfsd -d -r "$(nix-build "$(dirname "$0")/.." -A docs)"
