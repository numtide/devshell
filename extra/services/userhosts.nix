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
      description = ''
        The package containing the LD_PRELOAD library libuserhosts.so.
      '';
    };
    hosts = mkOption {
      type = types.attrsOf (types.listOf types.string);
      default = {};
      description = ''
        The host entries to use for userhosts.
        The top-level entries are the addresses where hostnames are resolved to.
        For each address you can supply a list of hostnames.
        This structure represents the structure you'd see in /etc/hosts.

        Note that, unlike /etc/hosts, you can also use names to resolve to as well.
      '';
      example = {
        "127.0.0.1" = [ "example.org" ];
        "myhost.local" = [ "mydomain.test" ];
      };
    };
  };

  config = mkIf (cfg.hosts != {}) (
    assert assertMsg pkgs.stdenv.isLinux "services.usershosts is only supported on Linux";
    {
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
    }
  );
}