let
  # nixpkgs is only used for development. Don't add it to the flake.lock.
  gitRev = "2c2a09678ce2ce4125591ac4fe2f7dfaec7a609c";
in
builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${gitRev}.tar.gz";
  sha256 = "1pkz5bq8f5p9kxkq3142lrrq1592d7zdi75fqzrf02cl1xy2cwvn";
}
