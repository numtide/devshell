{ lib, config, pkgs, ... }:
let
  cfg = config.language.rust;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  hasLibraries = lib.length cfg.libraries > 0;
  hasIncludes = lib.length cfg.includes > 0;
in
with lib;
{
  options.language.rust = {
    libraries = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Use this when another language dependens on a dynamic library";
    };

    includes = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Rust dependencies from nixpkgs";
    };

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
    }]
    ++
    (lib.optionals hasLibraries [
      {
        name = "LD_LIBRARY_PATH";
        prefix = "$DEVSHELL_DIR/lib";
      }
    ])
    ++ lib.optionals hasIncludes [
      {
        name = "LD_INCLUDE_PATH";
        prefix = "$DEVSHELL_DIR/include";
      }
      {
        name = "PKG_CONFIG_PATH";
        prefix = "$DEVSHELL_DIR/lib/pkgconfig";
      }
    ];

    devshell.packages =
      (lib.optionals hasLibraries (map lib.getLib cfg.libraries))
      ++
      # Assume we want pkg-config, because it's good
      (lib.optionals hasIncludes ([ pkgs.pkg-config ] ++ (map lib.getDev cfg.includes)))
      ++
      (map (tool: cfg.packageSet.${tool}) cfg.tools)
    ;
  };
}
