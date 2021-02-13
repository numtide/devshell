{ lib, config, pkgs, ... }:
let
  cfg = config.language.rust;
in
with lib;
{
  options.language.rust = {
    packageSet = mkOption {
      # FIXME: how to make the selection possible in TOML?
      type = types.attrs;
      default = pkgs.rustPackages;
      defaultText = "pkgs.rustPlatform";
      description = "Which rust package set to use";
    };

    tools = mkOption {
      type = types.listOf types.str;
      default = [
        "rustc"
        "cargo"
        "clippy"
        "rustfmt"
      ];
      description = "Which rust tools to pull from the platform package set";
    };
  };

  config = {
    env = [{
      # Used by tools like rust-analyzer
      name = "RUST_SRC_PATH";
      value = toString cfg.packageSet.rustPlatform.rustLibSrc;
    }];

    devshell.packages = map (tool: cfg.packageSet.${tool}) cfg.tools;
  };
}
