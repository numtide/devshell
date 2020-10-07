{ buildGoModule }:
let
  source = import ../nix/source.nix;
in
buildGoModule {
  name = "devshell";
  src = source.filter {
    path = ./.;
    allow = [
      ./go.mod
      ./go.sum
      (source.matchExt "go")
    ];
  };
  vendorSha256 = "sha256-NFsQoPDXEeOmyLR2bCgKuRHw2sjhGQbUmHV8bMJzANw=";
}
