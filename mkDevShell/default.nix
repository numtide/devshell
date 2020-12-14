{ lib
, bashInteractive
, buildEnv
, coreutils
, pkgs
, system
, writeText
, writeTextFile
, writeShellScriptBin
}:
let
  bashBin = "${bashInteractive}/bin";
  bashPath = "${bashInteractive}/bin/bash";

  # Transform the env vars into bash exports
  envToBash = env:
    builtins.concatStringsSep "\n"
      (lib.mapAttrsToList
        (k: v: "export ${k}=${lib.escapeShellArg (toString v)}")
        env
      )
  ;

  # A developer shell that works in all scenarios
  #
  # * nix-build
  # * nix-shell
  # * flake app
  # * direnv integration
  mkDevShell = module:
    let
      config = (lib.evalModules {
        modules = [ ./options.nix module ];
        args = {
          inherit pkgs;
        };
      }).config;

      inherit (config)
        bash
        commands
        env
        motd
        name
        packages
        ;

      envDrv = buildEnv {
        # TODO: support passing more arguments here
        name = "${name}-env";
        paths =
          let
            op = { name, command, ... }:
              assert lib.assertMsg (name != command) "[[commands]]: ${name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
              if command == null || command == "" then [ ]
              else [
                (writeShellScriptBin name (toString command))
              ];
          in
          (builtins.concatMap op commands) ++ packages;
      };

      # write a bash profile to load
      bashrc = writeText "${name}-bashrc" ''
        # Set all the passed environment variables
        ${envToBash env}

        # Prepend the PATH with the devshell dir and bash
        PATH=''${PATH#/path-not-set:}
        PATH=''${PATH#${bashBin}:}
        export PATH=$DEVSHELL_DIR/bin:${bashBin}:$PATH

        # Fill with sensible default for Ubuntu
        : "''${XDG_DATA_DIRS:=/usr/local/share:/usr/share}"
        # This is used by bash-completions to find new completions on demand
        export XDG_DATA_DIRS=$DEVSHELL_DIR/share:$XDG_DATA_DIRS

        # Expose the path to nixpkgs
        export NIXPKGS_PATH=${toString pkgs.path}

        # Load installed profiles
        for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
          # If that folder doesn't exist, bash loves to return the whole glob
          [[ -f "$file" ]] && source "$file"
        done

        # Use this to set even more things with bash
        ${bash.extra or ""}

        __devshell-motd() {
          cat <<DEVSHELL_PROMPT
        ${motd}
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
          PS1='\[\033[38;5;202m\][${name}]$(rel_root)\$\[\033[0m\] '
        fi

        ${bash.interactive or ""}

        fi # Interactive session
      '';

      # This is our entry-point for everything!
      devShellBin = derivation {
        inherit system;
        name = "${name}-bin";

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
          Usage: ${name}
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

      # Use this to define a flake app for the environment.
      flakeApp = {
        type = "app";
        program = "${devShellBin}";
      };

      # Use a naked derivation to limit the amount of noise passed to nix-shell.
      devShell = derivation {
        inherit name system;

        # `nix develop` actually checks and uses builder. And it must be bash.
        builder = bashPath;
        # Bring in the dependencies on `nix-build`
        args = [ "-ec" "${coreutils}/bin/ln -s ${devShellBin} $out; exit 0" ];

        # $stdenv/setup is loaded by nix-shell during startup.
        # https://github.com/nixos/nix/blob/377345e26f1ac4bbc87bb21debcc52a1d03230aa/src/nix-build/nix-build.cc#L429-L432
        stdenv = writeTextFile {
          name = "devshell-stdenv";
          destination = "/setup";
          text = ''
            # Fix for `nix develop`
            : ''${outputs:=out}

            runHook() {
              eval "$shellHook"
              unset runHook
            }
          '';
        };

        # The shellHook is loaded directly by `nix develop`. But nix-shell
        # requires that other trampoline.
        shellHook = ''
          # Remove all the unnecessary noise that is set by the build env
          unset NIX_BUILD_TOP NIX_BUILD_CORES NIX_BUILD_TOP NIX_STORE
          unset TEMP TEMPDIR TMP TMPDIR
          unset builder name out shellHook stdenv system
          # Flakes stuff
          unset dontAddDisableDepTrack outputs

          # For `nix develop`
          if [[ "$SHELL" == "/noshell" ]]; then
            export SHELL=${bashPath}
          fi

          # Load the dev shell environment
          source "${devShellBin}"
        '';
      };

      out = devShell // {
        inherit flakeApp;
      };
    in
    out
  ;

  # Build the devshell from pure JSON-like data
  fromData = data: mkDevShell data;

  importTOML = path: builtins.fromTOML (builtins.readFile path);

  # Build the devshell from a TOML declaration
  fromTOML = path: fromData (importTOML path);
in
{
  inherit
    fromData
    fromTOML
    importTOML
    mkDevShell
    ;

  __functor = _: mkDevShell;
}
