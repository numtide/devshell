#!/usr/bin/env bash
set -euo pipefail

# Update these
nix_bin_store_path=/nix/store/v6zncfrhmiz6flnrwi02rify3zrw6zdg-nix-2.4pre20201030_dc5696b-x86_64-unknown-linux-musl
nix_bin_hash=TODO

# Config
base_dir=$PWD
nix_bin_path=${base_dir}/.nix-bin
nix_bin_url=https://nar-serve.numtide.com${nix_bin_store_path}/bin/nix
store_dir=${base_dir}/nix-store

: "${NIX_PATH:=nixpkgs=channel:nixos-20.09}"

# Check if a program exists
has() {
  type -p "$1" &>/dev/null
}

# Small wrapper that runs the right nix command
nix_exec() (
  local name=$1
  shift
  exec -a "$name" "$nix_bin_path" "$@"
)

# If nix is already installed, use that. No need to override the store
if has nix ; then
  nix_bin_path=$(type -p nix)
else
  # Env vars
  unset \
    HOME \
    NIX_STATE_DIR \
    NIX_STORE_DIR

  # Bring your own Nix
  export NIX_CONFIG="store = $store_dir"
  export NIX_CONF_DIR=/homeless-shelter
  export NIX_PATH=nix=${store_dir}${nix_bin_store_path}/share/nix/corepkgs${NIX_PATH+:$NIX_PATH}
  export XDG_CACHE_DIR=$store_dir/cache

  # If inside of direnv, use fetchurl
  if has fetchurl &>/dev/null; then
    nix_bin_path=$(fetchurl "$nix_bin_url" "$nix_bin_hash")

  # Otherwise, fetch with curl
  elif [[ ! -f "$nix_bin_path" ]]; then
    curl -o "$nix_bin_path" "$nix_bin_url"
    chmod +x "$nix_bin_path"
  fi
fi

### Main ###

# Load the remaining Nix config
# TODO: --add-root --indirect
nix_exec nix-store --realize "$nix_bin_store_path" >/dev/null

# Finally run the command
nix_exec "$@"
