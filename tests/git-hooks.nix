{ pkgs, devshell }:
{
  # Basic git.hooks module tests
  git-hooks-1 =
    let
      shell1 = devshell.mkShell {
        devshell.name = "git-hooks-1a";
        git.hooks.enable = true;
        git.hooks.pre-commit.text = ''
          #!${pkgs.bash}/bin/bash
          echo "PRE-COMMIT"
        '';
      };

      shell2 = devshell.mkShell {
        devshell.name = "git-hooks-1b";
        git.hooks.enable = true;
      };
    in
    pkgs.runCommand "git-hooks-1" { nativeBuildInputs = [ pkgs.git ]; } ''
      git init

      # The hook doesn't exist yet
      [[ ! -L .git/hooks/pre-commit ]]

      # Load the devshell
      source ${shell1}

      # The hook has been install
      [[ -L .git/hooks/pre-commit ]]

      # The hook outputs what we want
      [[ $(.git/hooks/pre-commit) == "PRE-COMMIT" ]]

      # Load the new config
      source ${shell2}

      # The hook should have been uninstalled
      [[ ! -L .git/hooks/pre-commit ]]

      touch $out
    '';
}
