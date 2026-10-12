{ lib, config, pkgs, ... }:
let
  cfg = config.language.nodejs;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };
in
with lib;
{
  options.language.nodejs = {
    package = mkOption {
      type = strOrPackage;
      default = pkgs.nodejs; # latest
      example = literalExpression "pkgs.nodejs-18_x";
      description = "Which nodejs package to use";
    };
  };

  config = {
    devshell.packages = [
      cfg.package # nodejs itself

      # TODO: npm

      # Yarn
      (pkgs.yarn.override {
        nodejs = cfg.package;
      })

      # Pnpm
      (pkgs.nodePackages.pnpm.override {
        nodejs = cfg.package; # sadly doesn't suffice, but I found this:

        # From discourse: https://discourse.nixos.org/t/how-to-use-pnpm-with-recent-nodejs/21867/2?u=tennox
        nativeBuildInputs = [ pkgs.makeWrapper ];
        preRebuild = ''
          sed 's/"link:/"file:/g' --in-place package.json
        '';
        postInstall =
          let
            pnpmLibPath = pkgs.lib.makeBinPath [
              cfg.package.passthru.python
              cfg.package
            ];
          in
          ''
            for prog in $out/bin/*; do
              wrapProgram "$prog" --prefix PATH : ${pnpmLibPath}
            done
          '';
      })
    ];
  };
}
