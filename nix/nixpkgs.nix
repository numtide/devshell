let
  # nixpkgs is only used for development. Don't add it to the flake.lock.
  gitRev = "733e537a8ad76fd355b6f501127f7d0eb8861775";
in
builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${gitRev}.tar.gz";
  sha256 = "1rjvbycd8dkkflal8qysi9d571xmgqq46py3nx0wvbzwbkvzf7aw";
}
