{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.userhosts;
  hostsFile = pkgs.writeTextFile {
    name = "hosts";
    text =
      let
        lines = lib.mapAttrsToList
          (ip: hostnames: "${ip} ${builtins.concatStringsSep " " hostnames}")
          cfg.hosts;
      in
      "${builtins.concatStringsSep "\n" lines}\n";
  };
in
{
  options.services.userhosts = {
    package = mkOption {
      type = types.package;
      default = pkgs.userhosts;
    };
    hosts = mkOption {
      type = types.attrsOf (types.listOf types.string);
      default = {};
    };
  };

  config = mkIf (cfg.hosts != {}) {
    env = [
      {
        name = "HOSTS_FILE";
        value = "${hostsFile}";
      }
      {
        name = "LD_PRELOAD";
        prefix = "${cfg.package}/lib/libuserhosts.so";
      }
    ];
  };
}