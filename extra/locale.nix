{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.extra.locale;
in
{
  options.extra.locale = {
    lang = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Set the language of the project";
      example = "en_GB.UTF-8";
    };

    package = mkOption {
      type = types.package;
      description = "Set the glibc locale package that will be used on Linux";
      default = pkgs.glibcLocales;
      defaultText = "pkgs.glibcLocales";
    };
  };
  config.env =
    lib.optional pkgs.stdenv.isLinux {
      name = "LOCALE_ARCHIVE";
      value = "${cfg.package}/lib/locale/locale-archive";
    }
    ++ lib.optionals (cfg.lang != null) [
      {
        name = "LANG";
        value = cfg.lang;
      }
      {
        name = "LC_ALL";
        value = cfg.lang;
      }
    ];
}
