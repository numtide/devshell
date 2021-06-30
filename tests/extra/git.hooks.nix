{ pkgs, devshell, runTest }:
{
  # Basic git.hooks module tests
  git-hooks-1 =
    let
      shell1 = devshell.mkShell {
        imports = [ ../../extra/git/hooks.nix ];
        devshell.name = "git-hooks-1a";
        git.hooks.enable = true;
        git.hooks.pre-commit.text = ''
          #!${pkgs.bash}/bin/bash
          echo "PRE-COMMIT"
        '';
      };

      shell2 = devshell.mkShell {
        imports = [ ../../extra/git/hooks.nix ];
        devshell.name = "git-hooks-1b";
        git.hooks.enable = true;
      };
    in
    runTest "git-hooks-1" { nativeBuildInputs = [ pkgs.git ]; } ''
      git init

      # The hook doesn't exist yet
      assert_fail -L .git/hooks/pre-commit

      # Load the devshell
      source ${shell1}/env.bash

      # The hook has been install
      assert -L .git/hooks/pre-commit

      # The hook outputs what we want
      assert "$(.git/hooks/pre-commit)" == "PRE-COMMIT"

      # Load the new config
      source ${shell2}/env.bash

      # The hook should have been uninstalled
      assert_fail -L .git/hooks/pre-commit
    '';
}
