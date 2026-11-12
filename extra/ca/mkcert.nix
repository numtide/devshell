{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.mkcert;

  maybeReadFile = obj:
    if (builtins.typeOf obj == "path") then
      builtins.readFile obj
    else
      obj
  ;

  # These are all the options available for specifying a certificate/key file.
  rootCAOption = {
    key = mkOption {
      description = "Text or file of the root CA key to install";
      default = null;
      type = types.nullOr (types.either types.str types.path);
    };
    cert = mkOption {
      description = "Text or file of the root CA certificate to install";
      default = null;
      type = types.nullOr (types.either types.str types.path);
    };
  };

  # A collection of development certificate authority files
  rootCADir =
    let
      adHoc = pkgs.runCommandLocal "rootCA" {} ''
        export CAROOT=$out
        ${pkgs.mkcert}/bin/mkcert 2>/dev/null
      '';

      isPreconfigured =
        assert assertMsg (
          cfg.root-ca != {} && cfg.root-ca.cert != null && cfg.root-ca.key != null
        ) "[mkcert]: either set, both, root CA key and certificate or none.";
        (cfg.root-ca.key != null && cfg.root-ca.cert != null);

      key = pkgs.writeText "rootCA-key.pem" (maybeReadFile cfg.root-ca.key);
      cert = pkgs.writeText "rootCA.pem" (maybeReadFile cfg.root-ca.cert);

      preconfigured = pkgs.runCommand "rootCA" {} ''
        mkdir $out
        cp ${key} $out/${key.name}
        cp ${cert} $out/${cert.name}
      '';
    in
      if isPreconfigured then preconfigured else adHoc;

  # Execute this script to install the project's development certificate authority
  install-mkcert-ca = pkgs.writeShellScriptBin "install-mkcert-ca" ''
    set -euo pipefail
    shopt -s nullglob

    log() {
      IFS=$'\n' loglines=($*)
      for line in ${"$"}{loglines[@]}; do echo -e "[mkcert] $line" >&2; done
    }

    # Set the CA root files directory for mkcert via env variable
    export CAROOT=${rootCADir}

    # Install local CA into system, java and nss (includes Firefox) trust stores
    log "Install development CA into the system stores..."
    log $(sudo -K; ${pkgs.mkcert}/bin/mkcert -install 2>&1)
    log "root CA directory: $(${pkgs.mkcert}/bin/mkcert -CAROOT 2>&1)"

    uninstall() {
      log $(${pkgs.mkcert}/bin/mkcert -uninstall 2>&1)
    }

    # TODO: Uninstall when leaving the devshell
    # trap uninstall EXIT

  '';
in
{
  options.mkcert = {
    enable = mkEnableOption "provide a development CA within the shell";

    root-ca = mkOption {
      type = types.submodule { options = rootCAOption; };
      default = {};
      description = "preconfigure root CA files";
      example = literalExample "
        {
          key = ''
          -----BEGIN PRIVATE KEY-----
          ...
          -----END PRIVATE KEY-----
          '';
          cert = ./path/tocert.pem;
        }
      ";
    };
  };

  config = mkIf cfg.enable {
    env = [{
      name = "CAROOT";
      value = "${rootCADir}";
    }];
    commands = [ { package = pkgs.mkcert; category = "certs"; } ];
    devshell = {
      packages = [ install-mkcert-ca ];
      startup.install-mkcert-ca.text = "
        $DEVSHELL_DIR/bin/install-mkcert-ca
      ";
    };
  };
}
