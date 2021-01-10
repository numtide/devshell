{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.devshell;

  inherit (pkgs)
    bashInteractive
    buildEnv
    coreutils
    system
    writeScriptBin
    writeText
    ;

  ansi = import ../nix/ansi.nix;

  mkNakedShell = pkgs.callPackage ../nix/mkNakedShell.nix { };

  # Use this to define a flake app for the environment.
  mkFlakeApp = bin: {
    type = "app";
    program = "${bin}";
  };

  bashBin = "${bashInteractive}/bin";
  bashPath = "${bashInteractive}/bin/bash";

  # Transform the env vars into bash exports
  envToBash = env:
    builtins.concatStringsSep "\n"
      (lib.mapAttrsToList
        (k: v: "export ${k}=${lib.escapeShellArg (toString v)}")
        env
      );

  envDrv = buildEnv {
    name = "devshell-env";
    paths = cfg.paths;
  };

  # write a bash profile to load
  bashrc = writeText "devshell-bashrc" ''
    # Set all the passed environment variables
    ${envToBash config.environment.variables}

    # Prepend the PATH with the devshell dir and bash
    PATH=''${PATH#/path-not-set:}
    PATH=''${PATH#${bashBin}:}
    export PATH=$DEVSHELL_DIR/bin:${bashBin}:$PATH

    # Fill with sensible default for Ubuntu
    : "''${XDG_DATA_DIRS:=/usr/local/share:/usr/share}"
    # This is used by bash-completions to find new completions on demand
    export XDG_DATA_DIRS=$DEVSHELL_DIR/share:$XDG_DATA_DIRS

    # Load installed profiles
    for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
      # If that folder doesn't exist, bash loves to return the whole glob
      [[ -f "$file" ]] && source "$file"
    done

    # Use this to set even more things with bash
    ${config.bash.extra or ""}

    __devshell-motd() {
      cat <<DEVSHELL_PROMPT
    ${cfg.motd}
    DEVSHELL_PROMPT
    }

    # Print the motd in direnv
    if [[ ''${DIRENV_IN_ENVRC:-} = 1 ]]; then
      __devshell-motd
    fi

    # Interactive sessions
    if [[ $- == *i* ]]; then

    # Print information if the prompt is every displayed. We have to make
    # that distinction because `nix-shell -c "cmd"` is running in
    # interactive mode.
    __devshell-prompt() {
      __devshell-motd
      # Make it a noop
      __devshell-prompt() { :; }
    }
    PROMPT_COMMAND=__devshell-prompt''${PROMPT_COMMAND+;$PROMPT_COMMAND}

    # Set a cool PS1
    if [[ -n "$PS1" ]]; then
      # Print the path relative to $DEVSHELL_ROOT
      rel_root() {
        local path
        path=$(${coreutils}/bin/realpath --relative-to "$DEVSHELL_ROOT" "$PWD")
        if [[ $path != . ]]; then
          echo " $path "
        fi
      }
      PS1='\[\033[38;5;202m\][${cfg.name}]$(rel_root)\$\[\033[0m\] '
    fi

    ${config.bash.interactive or ""}

    fi # Interactive session
  '';

  # This is our entry-point for everything!
  activationPackage = derivation {
    inherit system;
    name = "${cfg.name}-bin";

    # Define our own minimal builder.
    builder = bashPath;
    args = [
      "-ec"
      ''
        ${coreutils}/bin/cp $envScriptPath $out &&
        ${coreutils}/bin/chmod +x $out;
        exit 0
      ''
    ];

    # The actual devshell wrapper script
    envScript = ''
      #!${bashPath}
      # Script that sets-up the environment. Can be both sourced or invoked.

      # This is the directory that contains our dependencies
      export DEVSHELL_DIR=${envDrv}
      # It assums that the shell is always loaded from the root of the project
      # Store that for later usage.
      export DEVSHELL_ROOT=$PWD

      # If the file is sourced, skip all of the rest and just source the
      # bashrc
      if [[ $0 != "''${BASH_SOURCE[0]}" ]]; then
        source "${bashrc}"
        return
      fi

      # Be strict!
      set -euo pipefail

      if [[ $# = 0 ]]; then
        # Start an interactive shell
        exec "${bashPath}" --rcfile "${bashrc}" --noprofile
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
        source "${bashrc}"
        exec -- "$@"
      fi
    '';

    passAsFile = [ "envScript" ];
  };
in
{
  options.devshell = {
    activationPackage = mkOption {
      internal = true;
      type = types.package;
      description = "The package containing the complete activation script.";
    };

    # TODO: rename motd to something better.
    motd = mkOption {
      type = types.str;
      default = ''
        ${ansi.orange}🔨 Welcome to ${cfg.name}${ansi.reset}
        $(menu)
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

    paths = mkOption {
      internal = true;
      type = types.listOf types.package;
      description = "List of packages.";
    };

    shell = mkOption {
      internal = true;
      type = types.package;
      description = "TODO";
    };
  };

  config.devshell = {
    activationPackage = activationPackage;

    # Use a naked derivation to limit the amount of noise passed to nix-shell.
    shell = mkNakedShell {
      name = cfg.name;
      script = cfg.activationPackage;
      passthru = {
        flakeApp = mkFlakeApp activationPackage;
      };
    };
  };
}
