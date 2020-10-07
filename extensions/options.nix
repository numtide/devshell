{ lib, pkgs, config, ... }:
with lib;
let
  inherit (config)
    name
    ;
  inherit (config.extensions)
    static-dns
    dev-ca-path
    ;

  installProjectCA = {
    name = "ca-install";
    help = "install dev CA";
    category = "host state";
    package = pkgs.mkcert;
    command = ''
      echo "$(tput bold)Installing the ${name}'s dev CA into local trust stores via mkcert command ...$(tput sgr0)"
      export CAROOT=${dev-ca-path}
      ${pkgs.mkcert}/bin/mkcert -install
    '';
  };
  uninstallProjectCA = {
    name = "ca-uninstall";
    help = "uninstall dev CA";
    category = "host state";
    package = pkgs.mkcert;
    command = ''
      echo "$(tput bold)Purging the ${name}'s dev CA from local trust stores via mkcert command ...$(tput sgr0)"
      export CAROOT=${dev-ca-path}
      ${pkgs.mkcert}/bin/mkcert -uninstall
    '';
  };

  etcHosts =
    pkgs.writeText "${name}-etchosts"
      (
        lib.concatStringsSep "\n"
          (lib.mapAttrsToList (name: value: value + " " + name) static-dns)
      );
  # since this temporarily modifies /etc/hosts, use of sudo can't be avoided
  fqdnsActivate = {
    name = "dns-activate";
    category = "host state";
    help = "activate pre-configured static dns";
    package = pkgs.hostctl;
    command = ''
      echo "$(tput bold)Installing ${name}'s static local DNS resolution via hostctl command ...$(tput sgr0)"
      sudo ${pkgs.hostctl}/bin/hostctl add ${name} --from ${etcHosts}
    '';
  };
  fqdnsDeactivate = {
    name = "dns-deactivate";
    category = "host state";
    help = "deactivate pre-configured static dns";
    package = pkgs.hostctl;
    command = ''
      echo "$(tput bold)Purging ${name}'s static local DNS resolution via hostctl command ...$(tput sgr0)"
      sudo ${pkgs.hostctl}/bin/hostctl remove ${name}
    '';
  };
  extensionOptions = {
    dev-ca-path = mkOption {
      type = types.str;
      default = "";
      description = ''
        Path to a development CA.

        Users can load/unload this dev CA easily and cleanly into their local
        trust stores via a wrapper around mkcert third party tool so that browsers
        and other tools would accept issued certificates under this CA as valid.

        Use cases:
         - Ship static dev certificates under version control and make them trusted
           on user machines: add the rootCA under version control alongside the
           your dev certificates.
         - Provide users with easy and reliable CA bootstrapping through the mkcert
           command: exempt this path from version control via .gitignore and have
           users  easily and reliably bootstrap a dev CA infrastructure on first use.
      '';
    };
    static-dns = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        A list of static DNS entries, for which to enable instrumentation.

        Users can enable/disable listed static DNS easily and cleanly
        via a wrapper around the hostctl third party tool.
      '';
      example = {
        "test.domain.local" = "172.0.0.1";
        "shared.domain.link-local" = "169.254.0.5";
      };
    };
  };
in
{
  options = {
    extensions = mkOption {
      type = types.submodule { options = extensionOptions; };
      default = [ ];
      description = ''
        Custom extensions to devshell.
      '';
    };
  };
  config = {
    commands =
      (
        if static-dns == null || static-dns == "" then [ ]
        else [ fqdnsActivate fqdnsDeactivate ]
      ) ++
      (
        if dev-ca-path == null || dev-ca-path == "" then [ ]
        else [ installProjectCA uninstallProjectCA ]
      );
  };
}
