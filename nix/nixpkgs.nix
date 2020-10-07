let
  # nixpkgs is only used for development. Don't add it to the flake.lock.
  gitRev = "500d695aac9ea67195812f309890a911fbc96bda";
in
builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${gitRev}.tar.gz";
  sha256 = "sha256-ya3rCWKDbPWMVsh89/Z1mCJ9HFa5/DKdjcgcKkWB1xs=";
}
