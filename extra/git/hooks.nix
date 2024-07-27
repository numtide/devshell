{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.git.hooks;

  # These are all the options available for a git hook.
  hookOptions = desc: {
    text = mkOption {
      description = "Text of the script to install";
      default = "";
      type = types.str;
    };
  };

  # All of the hook types supported by this module.
  allHooks = filterAttrs (k: v: k != "enable") cfg;

  # Only keep all the hooks that have a value set.
  hooksWithData = filterAttrs (k: v: v.text != "") allHooks;

  # Shims for all the hooks that this module supports.  The shims cause git
  # hooks to be ignored:
  #
  #   1. Outside of the devshell, or
  #   2. When the current devshell doesn't define/enable *any* git hooks, or
  #   3. When the current devshell doesn't define/enable the specific git hook
  #      in question.
  #
  # The idea here is to support scenarios like switching between multiple git
  # worktrees without having to reinstall the hook symlinks.  Instead, the hook
  # shims read the correct "real" shim (directory) from DEVSHELL_GIT_HOOKS_DIR,
  # which points to the directory containing git hooks for the current
  # devshell.
  hookShimsDir = pkgs.runCommand "git.hook.shims" { } ''
    mkdir -p $out/bin

    ${lib.concatMapStringsSep "\n" (k: ''
      cat <<'WRAPPER' > $out/bin/${k}
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      if [[ -z "''${DEVSHELL_DIR:-}" ]]; then
        echo "${k}: ignoring git hook outside of devshell"; >&2
        exit;
      elif [[ -z "''${DEVSHELL_GIT_HOOKS_DIR:-}" ]]; then
        echo "${k}: git hooks are not activated in this environment"; >&2
        exit;
      elif ! [[ -x "''${DEVSHELL_GIT_HOOKS_DIR}/bin/${k}" ]]; then
        echo "${k}: the ${k} git hook is not activated in this environment"; >&2
        exit;
      fi

      exec "''${DEVSHELL_GIT_HOOKS_DIR}/bin/${k}" "$@"
      WRAPPER

      # Mark as executable
      chmod +x "$out/bin/${k}"
    '') (builtins.attrNames allHooks)}
  '';

  # A collection of all the git hooks in the /bin folder
  hooksDir =
    let
      mkHookScript = k: hook: pkgs.writeShellScriptBin k hook.text;
    in
    pkgs.buildEnv {
      name = "git.hooks";
      paths = mapAttrsToList mkHookScript hooksWithData;
    };

  # Execute this script to update the project's git hooks
  install-git-hooks = pkgs.writeShellScriptBin "install-git-hooks" ''
    set -euo pipefail
    shopt -s nullglob

    log() {
      echo "[git.hooks] $*" >&2
    }

    update=0
    has_update() {
      if [[ $update == 0 ]]; then
        log "found updates"
        update=1
      fi
    }

    git_path_absolute() {
      ${pkgs.gitMinimal}/bin/git rev-parse --path-format=absolute "$@"
    }

    # Add `readlink -f` for macOS
    export PATH=${pkgs.coreutils}/bin:$PATH

    # Find the git dir
    git_work_tree=$(${pkgs.gitMinimal}/bin/git rev-parse --show-toplevel || true)
    if [[ $git_work_tree == "" ]]; then
      log "skipping as we can't find any .git folder, we are probably not in a git repository" >&2
      exit
    fi

    # Respect GIT_COMMON_DIR on git clients that support it
    git_dir=$(git_path_absolute --git-common-dir 2>/dev/null) || git_dir=$(git_path_absolute --git-dir)

    source_hook_dir=${hookShimsDir}/bin

    # Respect setups that define core.hooksPath
    target_hook_dir=$(git_path_absolute --git-path hooks/ 2>/dev/null) || target_hook_dir=$git_dir/hooks

    # Just in case it doesn't exist
    mkdir -pv "$target_hook_dir"

    # Iterate over all the hooks enabled for this environment
    for name in ${toString (attrNames hooksWithData)}; do
      # Resolve all the symlinks
      src_hook=$(readlink -f "$source_hook_dir/$name" || true)
      dst_hook=$(readlink -f "$target_hook_dir/$name" || true)

      # If the hook hasn't changed, skip
      if [[ "$src_hook" == "$dst_hook" ]]; then
        continue
      # If there is a new source hook, install
      elif [[ -f "$src_hook" ]]; then
        has_update
        ln -sfv "$src_hook" "$target_hook_dir/$name"
      fi
    done
    if [[ $update != 0 ]]; then
      log "done"
    fi
  '';
in
{
  options.git.hooks = {
    enable = mkEnableOption "install .git/hooks on shell entry";

    # TODO: add proper description for each hook.
    applypatch-msg = hookOptions "";
    commit-msg = hookOptions "";
    fsmonitor-watchman = hookOptions "";
    post-update = hookOptions "";
    pre-applypatch = hookOptions "";
    pre-commit = hookOptions "";
    pre-merge-commit = hookOptions "";
    prepare-commit-msg = hookOptions "";
    pre-push = hookOptions "";
    pre-rebase = hookOptions "";

    # Those are server-side hooks and probably don't make sense to have here?
    # post-receive = hookOptions "";
    # pre-receive = hookOptions "";
    # update = hookOptions "";
  };

  config.devshell = optionalAttrs cfg.enable {
    packages = [ install-git-hooks ];

    startup.install-git-hooks.text = "
      $DEVSHELL_DIR/bin/install-git-hooks
    ";
  };

  config.env = optional cfg.enable {
    name = "DEVSHELL_GIT_HOOKS_DIR";
    value = hooksDir;
  };
}
