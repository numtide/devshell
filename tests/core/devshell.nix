{ pkgs, devshell, runTest }:
{
  # Basic devshell package usage
  devshell-packages-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-1";
        devshell.packages = [ pkgs.git ];
      };
    in
    runTest "devshell-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Sets an environment variable that points to the buildEnv
      assert -n "$DEVSHELL_DIR"

      # Points DEVSHELL_ROOT to the project root
      assert "$PWD" == "$DEVSHELL_ROOT"

      # Adds packages to the PATH
      type -p git
    '';
}
