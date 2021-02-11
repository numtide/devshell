{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.devshell;

  ansi = import ../nix/ansi.nix;

  bashBin = "${cfg.bashPackage}/bin";
  bashPath = "${cfg.bashPackage}/bin/bash";

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  # Use this to define a flake app for the environment.
  mkFlakeApp = bin: {
    type = "app";
    program = "${bin}";
  };

  mkNakedShell = pkgs.callPackage ../nix/mkNakedShell.nix { };

  addAttributeName = prefix:
    mapAttrs (k: v: v // {
      text = ''
        #### ${prefix}.${k}
        ${v.text}
      '';
    });

  entryOptions = {
    text = mkOption {
      type = types.str;
      description = ''
        Script to run.
      '';
    };

    deps = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        A list of other steps that this one depends on.
      '';
    };
  };

  # Write a bash profile to load
  envBash = pkgs.writeText "devshell-env.bash" ''
    # Expose the folder that contains the assembled environment.
    export DEVSHELL_DIR=@devshellDir@

    # Prepend the PATH with the devshell dir and bash
    PATH=''${PATH%:/path-not-set}
    PATH=''${PATH#${bashBin}:}
    export PATH=$DEVSHELL_DIR/bin:${bashBin}:$PATH

    ${cfg.startup_env}

    ${textClosureMap id (addAttributeName "startup" cfg.startup) (attrNames cfg.startup)}

    # Interactive sessions
    if [[ $- == *i* ]]; then

    ${textClosureMap id (addAttributeName "interactive" cfg.interactive) (attrNames cfg.interactive)}

    fi # Interactive session
  '';

  # Builds the DEVSHELL_DIR with all the dependencies
  devshellDir = pkgs.buildEnv {
    name = "devshell-dir";
    paths = cfg.packages;
    postBuild = ''
      cp ${envBash} $out/env.bash
      substituteInPlace $out/env.bash --subst-var-by devshellDir $out
    '';
  };

  # This is our entry-point for everything!
  entrypoint = pkgs.writeShellScript "${cfg.name}-entrypoint" ''
    #!${bashPath}
    # Script that sets-up the environment. Can be both sourced or invoked.

    # It assums that the shell is always loaded from the root of the project.
    # Store that for later usage.
    export DEVSHELL_ROOT=$PWD

    # If the file is sourced, skip all of the rest and just source the env
    # script.
    if [[ $0 != "''${BASH_SOURCE[0]}" ]]; then
      source "${devshellDir}/env.bash"
      return
    fi

    # Be strict!
    set -euo pipefail

    if [[ $# = 0 ]]; then
      # Start an interactive shell
      exec "${bashPath}" --rcfile "${devshellDir}/env.bash" --noprofile
    elif [[ $1 == "-h" || $1 == "--help" ]]; then
      cat <<USAGE
    Usage: ${cfg.name}
      source $0               # load the environment in the current bash
      $0 -h | --help          # show this help
      $0 [--pure]             # start a bash sub-shell
      $0 [--pure] <cmd> [...] # run a command in the environment

    Options:
      * --pure : execute the script in a clean environment
    USAGE
      exit
    elif [[ $1 == "--pure" ]]; then
      # re-execute the script in a clean environment
      shift
      exec -c "$0" "$@"
    else
      # Start a script
      source "${devshellDir}/env.bash"
      exec -- "$@"
    fi
  '';
in
{
  options.devshell = {
    bashPackage = mkOption {
      internal = true;
      type = strOrPackage;
      default = pkgs.bashInteractive;
      defaultText = "pkgs.bashInteractive";
      description = "Version of bash to use in the project";
    };

    entrypoint = mkOption {
      internal = true;
      type = types.package;
      description = ''
        This package contains a script that loads the current environment.
      '';
    };

    startup = mkOption {
      type = types.attrsOf (types.submodule { options = entryOptions; });
      default = { };
      internal = true;
      description = ''
        A list of scripts to execute on startup.
      '';
    };

    startup_env = mkOption {
      type = types.str;
      default = "";
      internal = true;
      description = ''
        Please ignore. Used by the env module.
      '';
    };

    interactive = mkOption {
      type = types.attrsOf (types.submodule { options = entryOptions; });
      default = { };
      internal = true;
      description = ''
        A list of scripts to execute on interactive startups.
      '';
    };

    # TODO: rename motd to something better.
    motd = mkOption {
      type = types.str;
      default = ''
        ${ansi.orange}🔨 Welcome to ${cfg.name}${ansi.reset}
        $(type -p menu &>/dev/null && menu)
      '';
      description = ''
        Message Of The Day.

        This is the welcome message that is being printed when the user opens
        the shell.
      '';
    };

    name = mkOption {
      type = types.str;
      default = "devshell";
      description = ''
        Name of the shell environment. It usually maps to the project name.
      '';
    };

    packages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = ''
        The set of packages to appear in the project environment.

        Those packages come from <https://nixos.org/NixOS/nixpkgs> and can be
        searched by going to <https://search.nixos.org/packages>
      '';
    };

    shell = mkOption {
      internal = true;
      type = types.package;
      description = "TODO";
    };
  };

  config.devshell = {
    entrypoint = entrypoint;

    startup = {
      load_profiles = noDepEntry ''
        # Load installed profiles
        for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
          # If that folder doesn't exist, bash loves to return the whole glob
          [[ -f "$file" ]] && source "$file"
        done
      '';

      motd = noDepEntry ''
        __devshell-motd() {
          cat <<DEVSHELL_PROMPT
        ${cfg.motd}
        DEVSHELL_PROMPT
        }

        # Print the motd in direnv
        if [[ ''${DIRENV_IN_ENVRC:-} = 1 ]]; then
          __devshell-motd
        else
          # Print information if the prompt is displayed. We have to make
          # that distinction because `nix-shell -c "cmd"` is running in
          # interactive mode.
          __devshell-prompt() {
            __devshell-motd
            # Make it a noop
            __devshell-prompt() { :; }
          }
          PROMPT_COMMAND=__devshell-prompt''${PROMPT_COMMAND+;$PROMPT_COMMAND}
        fi
      '';
    };

    interactive = {
      PS1 = noDepEntry ''
        # Set a cool PS1
        if [[ -n "''${DEVSHELL_ROOT:-}" ]]; then
          # Print the path relative to $DEVSHELL_ROOT
          rel_root() {
            local path
            path=$(${pkgs.coreutils}/bin/realpath --relative-to "$DEVSHELL_ROOT" "$PWD")
            if [[ $path != . ]]; then
              echo " $path "
            fi
          }
        else
          # If DEVSHELL_ROOT is unset, print only the current directory name
          rel_root() {
            echo " \W "
          }
        fi
        PS1='\[\033[38;5;202m\][${cfg.name}]$(rel_root)\$\[\033[0m\] '
      '';
    };

    # Use a naked derivation to limit the amount of noise passed to nix-shell.
    shell = mkNakedShell {
      name = cfg.name;
      script = cfg.entrypoint;
      passthru = {
        inherit config;
        flakeApp = mkFlakeApp entrypoint;
      };
    };
  };
}
