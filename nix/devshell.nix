{ buildGoModule }:
let
  source = import ./source.nix;
in
buildGoModule {
  name = "devshell";
  src = source.filter {
    path = ../devshell;
    allow = [
      ../devshell/go.mod
      ../devshell/go.sum
      ../devshell/cmd
      ../devshell/config
      (source.matchExt "go")
    ];
  };
  vendorSha256 = "sha256-NFsQoPDXEeOmyLR2bCgKuRHw2sjhGQbUmHV8bMJzANw=";
}
