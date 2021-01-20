{ system ? builtins.currentSystem }:
let
  nixpkgs = import ../nix/nixpkgs.nix;

  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };

  configuration = with pkgs.lib; {
    config.modules-docs.baseURL = "https://example.com";

    options.test = mkOption {
      type = types.str;
      default = "XXX";
      description = ''
        This is a description.
      '';
    };
  };

  module = pkgs.lib.evalModules {
    modules = [ ../modules/modules-docs.nix configuration ];
    specialArgs = {
      modulesPath = builtins.toString ../modules;
    };
  };
in
module
