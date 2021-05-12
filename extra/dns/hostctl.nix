{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.hostctl;
  profile = toLower config.devshell.name;

  etcHosts = pkgs.writeText "${profile}-etchosts" (
    concatStringsSep "\n"
      (mapAttrsToList (host: ip: ip + " " + host) cfg.dns)
  );

  # Execute this script to install the project's static dns entries
  install-hostctl-dns = pkgs.writeShellScriptBin "install-hostctl-dns" ''
    set -euo pipefail
    shopt -s nullglob

    log() {
      IFS=$'\n' loglines=($*)
      for line in ${"$"}{loglines[@]}; do echo -e "[hostctl] $line" >&2; done
    }

    # Install local CA into system, java and nss (includes Firefox) trust stores
    log "Update static dns entries..."
    sudo -K
    log $(sudo ${pkgs.hostctl}/bin/hostctl add ${profile} --from ${etcHosts} 2>&1)

    uninstall() {
      log $(sudo ${pkgs.hostctl}/bin/hostctl remove ${profile} 2>&1)
    }

    # TODO: Uninstall when leaving the devshell
    # trap uninstall EXIT

  '';
in
{
  options.hostctl = {
    enable = mkEnableOption "manage temporary /etc/host entries for development from within the shell";

    dns = mkOption {
      type = types.attrs;
      default = {};
      description = "configure static dns entries";
      example = literalExample ''
        {
          dns."some.host" = "1.2.3.4";
          dns."another.host" = "4.3.2.1";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    commands = [ { package = pkgs.hostctl; category = "dns"; } ];
    devshell = {
      packages = [ install-hostctl-dns ];
      startup.install-hostctl-dns.text = "
        $DEVSHELL_DIR/bin/install-hostctl-dns
      ";
    };
  };
}
