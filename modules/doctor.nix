{ lib, config, pkgs }:
with lib;
let
  cfg = config.doctor;

  doctor-script = pkgs.writeShellScriptBin "doctor" ''
    set -euo pipefail


  '';

  checkOptions = {
    name = mkOption {
      description = "Name of the check";
      type = types.str;
    };

    script = mkOption {
      description = ''
        Bash snippet that verifies something and fails if the returned exit
        status is > 0.
      '';
    };
  };
in
{
  options.doctor = {
    enable = mkEnableOption "doctor";

    checks = mkOption {
      description = "Checks to execute on entering the environment";
      type = types.listOf (types.submodule { options = checkOptions; });
    };

    config = optionalAttrs cfg.enable {
      devshell = {
        packages = [ doctor-script ];
        startup.doctor.text = "
          doctor
        ";
      };
    };
  }
