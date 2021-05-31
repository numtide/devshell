{ lib, config, pkgs, ... }:
let
  cfg = config.language.c;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  hasLibraries = lib.length cfg.libraries > 0;
  hasIncludes = lib.length cfg.includes > 0;
in
with lib;
{
  options.language.c = {
    compiler = mkOption {
      type = strOrPackage;
      default = pkgs.clang;
      defaultText = "pkgs.clang";
      description = ''
        Which C compiler to use.

        For gcc, use pkgs.gcc-unwrapped.
      '';
    };

    linker = mkOption {
      type = strOrPackage;
      default = pkgs.binutils;
      defaultText = "pkgs.binutils";
      description = "Which linker package to use";
    };

    libraries = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Use this when another language dependens on a dynamic library";
      example = lib.literalExample ''
        [ pkgs.glibc ]
      '';
    };

    pkg-config = mkEnableOption "use pkg-config";

    includes = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "C dependencies from nixpkgs";
    };

  };

  config = {
    devshell.packages =
      [ cfg.compiler cfg.linker ]
      ++
      (lib.optionals hasLibraries (map lib.getLib cfg.libraries))
      ++
      (lib.optional cfg.pkg-config pkgs.pkg-config)
    ;

    env =
      (lib.optionals hasLibraries [
        {
          name = "LIBRARY_PATH";
          value = lib.concatStringsSep ":" (map (x: "${lib.getLib x}/lib") cfg.libraries);
        }
      ])
      ++ (lib.optional hasIncludes {
        name = "LD_INCLUDE_PATH";
        prefix = "$DEVSHELL_DIR/include";
      })
      ++ (lib.optional cfg.pkg-config {
        name = "PKG_CONFIG_PATH";
        value = lib.concatStringsSep ":" (map (x: "${lib.getLib x}/lib/pkgconfig") cfg.libraries);
      })
    ;
  };
}
