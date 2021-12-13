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

      # Points PRJ_ROOT to the project root
      assert "$PWD" == "$PRJ_ROOT"

      # Adds packages to the PATH
      type -p git
    '';

  # Only load profiles
  devshell-load-profiles-1 =
    let
      fakeProfile = pkgs.writeTextFile {
        name = "fake_profile.sh";
        destination = "/etc/profile.d/fake_profile.sh";
        text = ''
          export FAKE_PROFILE=1
        '';
      };

      shell = devshell.mkShell {
        devshell.name = "devshell-1";
        devshell.load_profiles = true;
        devshell.packages = [ fakeProfile ];
      };
    in
    runTest "devshell-load-profiles-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Check that the profile got loaded
      assert "$FAKE_PROFILE" == "1"
    '';
}
