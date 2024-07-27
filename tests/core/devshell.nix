{
  pkgs,
  devshell,
  runTest,
}:
{
  # Basic devshell package usage
  devshell-packages-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-1";
        devshell.packages = [ pkgs.git ];
        devshell.packagesFrom = [
          (pkgs.hello.overrideAttrs {
            buildInputs = [
              null
              pkgs.cowsay
            ];
          })
        ];
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

      # Adds packages from packagesFrom to the PATH
      type -p cowsay
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

  # Devshell entrypoint script features
  devshell-entrypoint-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-entrypoint-1";
        devshell.packages = [ pkgs.git ];

        # Force PRJ_ROOT to be defined by caller (possibly via `--prj-root`).
        devshell.prj_root_fallback = null;
      };
    in
    runTest "devshell-entrypoint-1" { } ''
      entrypoint_clean() {
        env -u IN_NIX_SHELL -u PRJ_ROOT ${shell}/entrypoint "$@"
      }

      # No packages in PATH
      ! type -p git

      # Exits badly if PRJ_ROOT isn't set, or if we cannot assume PRJ_ROOT
      # should be PWD.
      ! msg="$(entrypoint_clean /bin/sh -c 'exit 0' 2>&1)"
      assert "$msg" == 'ERROR: please set the PRJ_ROOT env var to point to the project root'

      # Succeeds with --prj-root set
      entrypoint_clean --prj-root . /bin/sh -c 'exit 0'

      # Packages available through entrypoint
      entrypoint_clean --prj-root . /bin/sh -c 'type -p git'

      # Packages available through entrypoint in pure mode
      entrypoint_clean --pure --env-bin env --prj-root . /bin/sh -c 'type -p git'
    '';

  # Use devshell as executable
  devshell-executable-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-executable-1";
        devshell.packages = [ pkgs.hello ];
      };
    in
    runTest "devshell-executable-1" { } ''
      # Devshell is executable
      assert -x ${pkgs.lib.getExe shell}

      # Packages inside the devshell are executable
      ${pkgs.lib.getExe shell} hello
    '';
}
