{
  lib,
  config,
  pkgs,
  ...
}:
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
    enableDefaultToolchain = mkOption {
      type = types.bool;
      default = true;
      defaultText = "true";
      description = "Enable the default rust toolchain coming from nixpkgs";
    };
  };

  config = {
    devshell.packages =
      if cfg.enableDefaultToolchain then (map (tool: cfg.packageSet.${tool}) cfg.tools) else [ ];
    env =
      [
        {
          # On darwin for example enables finding of libiconv
          name = "LIBRARY_PATH";
          # append in case it needs to be modified
          eval = "$DEVSHELL_DIR/lib";
        }
        {
          # some *-sys crates require additional includes
          name = "CFLAGS";
          # append in case it needs to be modified
          eval = "\"-I $DEVSHELL_DIR/include ${lib.optionalString pkgs.stdenv.isDarwin "-iframework $DEVSHELL_DIR/Library/Frameworks"}\"";
        }
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        {
          # On darwin for example required for some *-sys crate compilation
          name = "RUSTFLAGS";
          # append in case it needs to be modified
          eval = "\"-L framework=$DEVSHELL_DIR/Library/Frameworks\"";
        }
        {
          # rustdoc uses a different set of flags
          name = "RUSTDOCFLAGS";
          # append in case it needs to be modified
          eval = "\"-L framework=$DEVSHELL_DIR/Library/Frameworks\"";
        }
        {
          name = "PATH";
          prefix =
            let
              inherit (pkgs) xcbuild;
            in
            lib.makeBinPath [
              xcbuild
              "${xcbuild}/Toolchains/XcodeDefault.xctoolchain"
            ];
        }
      ]
      # fenix provides '.rust-src' in the 'complete' toolchain configuration
      ++ lib.optionals (cfg.enableDefaultToolchain && cfg.packageSet ? rust-src) [
        {
          # rust-analyzer may use this to quicker find the rust source
          name = "RUST_SRC_PATH";
          value = "${cfg.packageSet.rust-src}/lib/rustlib/src/rust/library";
        }
      ];
  };
}
