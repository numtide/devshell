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

# Env vars
unset \
  HOME \
  NIX_STATE_DIR \
  NIX_STORE_DIR

: "${NIX_PATH:=nixpkgs=channel:nixos-20.09}"

export NIX_CONFIG="store = $store_dir"
export NIX_CONF_DIR=/homeless-shelter
export NIX_DATA_DIR=${store_dir}${nix_bin_store_path}
export NIX_PATH=nix=${store_dir}${nix_bin_store_path}/share/nix/corepkgs${NIX_PATH+:$NIX_PATH}
export XDG_CACHE_DIR=$store_dir/cache

# Fetch Nix
if type -f fetchurl &>/dev/null; then
  nix_bin_path=$(fetchurl "$nix_bin_url" "$nix_bin_hash")
elif [[ ! -f "$nix_bin_path" ]]; then
  curl -o "$nix_bin_path" "$nix_bin_url"
  chmod +x "$nix_bin_path"
fi

#
nix_exec() (
  # shellcheck disable=SC2030,SC2031
  name=$1
  shift
  exec -a "$name" "$nix_bin_path" "$@"
)

### Main ###

# Load the remaining Nix config
nix_exec nix-store --realize "$nix_bin_store_path"

# Finally run the command
nix_exec "${0/.sh//}" "$@"
