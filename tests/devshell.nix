{ pkgs, devshell }:
{
  # Basic devshell usage
  devshell-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-1";
        devshell.packages = [ pkgs.git ];
      };
    in
    pkgs.runCommand "devshell-1" { } ''
      # Load the devshell
      source ${shell}

      # Sets an environment variable that points to the buildEnv
      [[ -n $DEVSHELL_DIR ]]

      # Points DEVSHELL_ROOT to the project root
      [[ $PWD == "$DEVSHELL_ROOT" ]]

      # Adds packages to the PATH
      type -p git

      touch $out
    '';
}
