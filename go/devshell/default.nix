{ lib, buildGoModule }:
buildGoModule {
  name = "devshell";
  src = lib.cleanSource ./.;
  vendorSha256 = "sha256-CksQhzcKuHWihdJeTazQ5EG8aFkZ5cpss90eRCT+ERc=";
}
