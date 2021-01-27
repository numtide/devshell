{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.git.hooks;

  # These are all the options available for a git hook.
  hookOptions = desc:
    {
      text = mkOption {
        description = "Text of the script to install";
        default = "";
        type = types.str;
      };
    };

  # Only keep all the hooks that have a value set.
  hooksWithData = filterAttrs (k: v: k != "enable" && v.text != "") cfg;

  # A collection of all the git hooks in the /bin folder
  hooksDir =
    let
      mkHookScript = k: hook:
        pkgs.runCommand k
          {
            text = hook.text;
            passAsFile = [ "text" ];
          }
          ''
            mkdir -p $out/bin

            cp "$textPath" "$out/bin/.${k}-wrapped"

            # Add a wrapper so that the hooks are ignored outside of the
            # devshell.
            cat <<'WRAPPER' > $out/bin/${k}
            #!${pkgs.bash}/bin/bash
            set -euo pipefail

            if [[ -z "''${DEVSHELL_DIR:-}" ]]; then
              echo "${k}: ignoring git hook outside of devshell"; >&2
              exit;
            fi
            exec "@out@/bin/.${k}-wrapped" "$@"
            WRAPPER
            sed -e "s|@out@|$out|g" -i "$out/bin/${k}"

            # Mark as executable
            chmod +x "$out/bin/.${k}-wrapped" "$out/bin/${k}"
          '';
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

    # Add `readlink -f` for macOS
    export PATH=${pkgs.coreutils}/bin:$PATH

    # Find the git dir
    git_work_tree=$(git rev-parse --show-toplevel)
    git_dir=$(git rev-parse --absolute-git-dir)
    source_hook_dir=${hooksDir}/bin
    target_hook_dir=$git_dir/hooks

    if [[ "$git_dir" != "$git_work_tree"/.git ]]; then
      # There are cases where the '.git' folder lives in other places. For
      # example the `git worktree` command. In these cases, don't touch the
      # git hooks because they are shared between the various checkouts.
      log "skipping as this worktree doen't contain the .git folder" >&2
      exit
    fi

    # Just in case it doesn't exist
    mkdir -pv "$target_hook_dir"

    # Iterate over all the hooks we know of
    for name in ${toString (filter (name: name != "enable") (attrNames cfg))}; do
      # Resolve all the symlinks
      src_hook=$(readlink -f "$source_hook_dir/$name")
      dst_hook=$(readlink -f "$target_hook_dir/$name")

      # If the hook hasn't changed, skip
      if [[ "$src_hook" == "$dst_hook" ]]; then
        continue
      # If there is a new source hook, install
      elif [[ -f "$src_hook" ]]; then
        has_update
        ln -sfv "$src_hook" "$target_hook_dir/$name"
      # If the target hook is a store path, assume it's an old hook and
      # remove. Don't touch other existing hooks.
      elif [[ "$dst_hook" == ${builtins.storeDir}/* ]]; then
        has_update
        rm -v "$target_hook_dir/$name"
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
}
