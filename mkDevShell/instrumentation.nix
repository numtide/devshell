{ lib, pkgs, config }:
let
  inherit (config)
    name
    dev-ca-path
    static-dns
    ;
  installProjectCA = {
    name = "ca-install";
    help = "install dev CA";
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
    package = pkgs.mkcert;
    command = ''
      echo "$(tput bold)Purging the ${name}'s dev CA from local trust stores via mkcert command ...$(tput sgr0)"
      export CAROOT=${dev-ca-path}
      ${pkgs.mkcert}/bin/mkcert -uninstall
    '';
  };

  etcHosts = pkgs.writeText "${name}-etchosts"
    (lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: value: value + " " + name) static-dns)
    );
  # since this temporarily modifies /etc/hosts, use of sudo can't be avoided
  fqdnsActivate = {
    name = "dns-activate";
    help = "activate pre-configured static dns";
    package = pkgs.hostctl;
    command = ''
      echo "$(tput bold)Installing ${name}'s static local DNS resolution via hostctl command ...$(tput sgr0)"
      sudo ${pkgs.hostctl}/bin/hostctl add ${name} --from ${etcHosts}
    '';
  };
  fqdnsDeactivate = {
    name = "dns-deactivate";
    help = "deactivate pre-configured static dns";
    package = pkgs.hostctl;
    command = ''
      echo "$(tput bold)Purging ${name}'s static local DNS resolution via hostctl command ...$(tput sgr0)"
      sudo ${pkgs.hostctl}/bin/hostctl remove ${name}
    '';
  };
in
(
  if static-dns == null || static-dns == "" then [ ]
  else [ fqdnsActivate fqdnsDeactivate ]
) ++
(
  if dev-ca-path == null || dev-ca-path == "" then [ ]
  else [ installProjectCA uninstallProjectCA ]
)
