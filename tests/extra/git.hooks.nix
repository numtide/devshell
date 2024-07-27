{
  pkgs,
  devshell,
  runTest,
}:
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

      shell3 = devshell.mkShell { devshell.name = "git-hooks-1c"; };

      shell4 = devshell.mkShell {
        imports = [ ../../extra/git/hooks.nix ];
        devshell.name = "git-hooks-1d";
        git.hooks.enable = true;
        git.hooks.pre-commit.text = ''
          #!${pkgs.bash}/bin/bash
          echo "PRE-COMMIT-OF-ANOTHER-COLOR"
        '';
        git.hooks.pre-rebase.text = ''
          #!${pkgs.bash}/bin/bash
          echo "NOPE"
          exit 1
        '';
      };
    in
    runTest "git-hooks-1" { nativeBuildInputs = [ pkgs.git ]; } ''
      mkdir worktree-1

      cd worktree-1

      git init -b git-hook-test

      # Set up fake config values in order to make a commit
      git config user.email test@ing.123
      git config user.name "Test User"

      # Make a commit in order to add worktrees
      git commit --allow-empty -m init

      git_dir=$(${pkgs.gitMinimal}/bin/git rev-parse --absolute-git-dir)
      git_hooks_path=$(git rev-parse --path-format=absolute --git-path hooks/ 2>/dev/null) \
        || git_hooks_path="''${git_dir}/hooks"

      git_pre_commit_hook="''${git_hooks_path}/pre-commit"

      # The hook doesn't exist yet
      assert_fail -L "$git_pre_commit_hook"

      # Load the devshell
      source ${shell1}/env.bash

      # The hook has been installed
      assert -L "$git_pre_commit_hook"

      # The hook outputs what we want
      assert "$("$git_pre_commit_hook")" == "PRE-COMMIT"

      # Load the new config
      source ${shell2}/env.bash

      # This specific hook should complain that it is not activated
      assert "$("$git_pre_commit_hook")" == "pre-commit: the pre-commit git hook is not activated in this environment"

      # Load a config with no hooks defined
      # NOTE need to unset the hooks dir environment variable as this profile
      # does not enable git hooks and therefore does not (re)set the variable
      unset DEVSHELL_GIT_HOOKS_DIR
      source ${shell3}/env.bash

      # The hook should complain that *no* hooks are activated
      assert "$("$git_pre_commit_hook")" == "pre-commit: git hooks are not activated in this environment"

      git worktree add ../worktree-2

      cd ../worktree-2

      # Now source initial profile
      source ${shell1}/env.bash

      # The hook has been reinstalled
      assert -L "$git_pre_commit_hook"

      # The hook outputs what we want
      assert "$("$git_pre_commit_hook")" == "PRE-COMMIT"

      # Stash current pre-commit hook link path for later testing
      git_pre_commit_real="$(readlink -f "$git_pre_commit_hook")"

      # Added by shell4
      git_pre_rebase_hook="''${git_hooks_path}/pre-rebase"

      # Only shell4 has this hook
      assert_fail -L "$git_pre_rebase_hook"

      # Now source the profile that defines a pre-rebase hook
      source ${shell4}/env.bash

      # Pre-rebase hook should now exist
      assert -L "$git_pre_rebase_hook"

      # Stash pre-rebase hook link path for later testing
      git_pre_rebase_real="$(readlink -f "$git_pre_rebase_hook")"

      # The hook outputs what we want
      assert "$("$git_pre_commit_hook")" == "PRE-COMMIT-OF-ANOTHER-COLOR"

      # Pre-commit link should not have changed
      assert "$git_pre_commit_real" = "$(readlink -f "$git_pre_commit_hook")"

      # Switch back to profile without pre-rebase hook
      source ${shell1}/env.bash

      # Pre-rebase link should not have changed
      assert "$git_pre_rebase_real" = "$(readlink -f "$git_pre_rebase_hook")"
    '';
}
