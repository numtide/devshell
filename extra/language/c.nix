{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.language.c;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  hasLibraries = lib.length cfg.libraries > 0;
  hasIncludes = lib.length cfg.includes > 0;
in
with lib;
{
  options.language.c = {
    libraries = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Use this when another language dependens on a dynamic library";
    };

    includes = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "C dependencies from nixpkgs";
    };

    compiler = mkOption {
      type = strOrPackage;
      default = pkgs.clang;
      defaultText = "pkgs.clang";
      description = "Which C compiler to use";
    };
  };

  config = {
    devshell.packages =
      [ cfg.compiler ]
      ++ (lib.optionals hasLibraries (map lib.getLib cfg.libraries))
      ++
        # Assume we want pkg-config, because it's good
        (lib.optionals hasIncludes ([ pkgs.pkg-config ] ++ (map lib.getDev cfg.includes)));

    env =
      (lib.optionals hasLibraries [
        {
          name = "LD_LIBRARY_PATH";
          prefix = "$DEVSHELL_DIR/lib";
        }
        {
          name = "LDFLAGS";
          eval = "-L$DEVSHELL_DIR/lib";
        }
      ])
      ++ lib.optionals hasIncludes [
        {
          name = "C_INCLUDE_PATH";
          prefix = "$DEVSHELL_DIR/include";
        }
        {
          name = "PKG_CONFIG_PATH";
          prefix = "$DEVSHELL_DIR/lib/pkgconfig";
        }
      ];
  };
}
