{ lib
, bashInteractive
, buildEnv
, coreutils
, gnused
, pkgs
, system
, writeText
, writeTextFile
, writeShellScriptBin
}:
let
  bashBin = "${bashInteractive}/bin";
  bashPath = "${bashInteractive}/bin/bash";

  # transform the env vars into bash instructions
  envToBash = env:
    builtins.concatStringsSep "\n"
      (lib.mapAttrsToList
        (k: v: "export ${k}=${lib.escapeShellArg (toString v)}")
        env
      )
  ;

  commandsToBash = commands:
    let
      op = { name, alias, ... }:
        if alias == null || alias == "" then "" else
        "alias ${name}=${lib.escapeShellArg (toString alias)}";
    in
    builtins.concatStringsSep "\n" (map op commands)
  ;

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str
  ;

  commandsToMenu = commands:
    let
      commandsSorted = builtins.sort (a: b: a.name < b.name) commands;

      commandLengths =
        map ({ name, ... }: builtins.stringLength name) commandsSorted;

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      op = { name, help, ... }:
        let
          len = maxCommandLength - (builtins.stringLength name);
        in
        if help == null || help == "" then
          name
        else
          "${pad name len} - ${help}"
      ;

    in
    builtins.concatStringsSep "\n" (map op commandsSorted)
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
        name = "${name}-env";
        paths = packages;
        # TODO: support passing more arguments here
      };

      # write a bash profile to load
      bashrc = writeText "${name}-bashrc" ''
        # Set all the passed environment variables
        ${envToBash env}

        # Prepend the PATH with the devshell dir and bash
        PATH=''${PATH#/path-not-set:}
        PATH=''${PATH#${bashBin}:}
        export PATH=$DEVSHELL_DIR/bin:${bashBin}:$PATH

        export NIXPKGS_PATH=${toString pkgs.path}

        # Load installed profiles
        for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
          # if that folder doesn't exist, bash loves to return the whole glob
          [[ -e "$file" ]] || continue
          source "$file"
        done

        # Use this to set even more things with bash
        ${bash.extra or ""}

        # Interactive sessions
        if [[ $- == *i* ]]; then

        devshell-menu() {
          echo "### 🔨 Welcome to ${name} ####"
          echo
          echo "# Commands"
          echo
          cat <<'DEVSHELL_MENU'
        ${commandsToMenu commands}
        DEVSHELL_MENU
        }

        # Type `devshell-root` to go back to the project root
        devshell-root() {
          cd "$DEVSHELL_ROOT"
        }

        # Print information if the prompt is every displayed. We have to make
        # that distinction because `nix-shell -c "cmd"` is running in
        # interactive mode.
        devshell-prompt() {
          cat <<DEVSHELL_PROMPT
        ${motd}
        DEVSHELL_PROMPT
          # Make it a noop
          devshell-prompt() { :; }
        }
        PROMPT_COMMAND=devshell-prompt''${PROMPT_COMMAND+;$PROMPT_COMMAND}

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
          PS1='\[\033[0;32;40m\][${name}]$(rel_root)\$\[\033[0m\] '
        fi

        # Load bash completions
        for file in "$DEVSHELL_DIR/share/bash-completion/completions/"* ; do
          [[ -f "$file" ]] && source "$file"
        done

        ${commandsToBash commands}

        ${bash.interactive or ""}

        fi # Interactive session
      '';

      # This is our entrypoint for everything!
      devShellBin = derivation {
        inherit system;
        name = "${name}-bin";

        # Define our own minimal builder.
        builder = bashPath;
        args = [ "-ec" ". $buildScriptPath" ];
        buildScript = ''
          ${coreutils}/bin/cp $envScriptPath $out
          ${coreutils}/bin/chmod +x $out
        '';

        # Break the stdenv on purpose to avoid nix-shell here
        stdenv = writeTextFile {
          name = "devshell-stdenv";
          destination = "/setup";
          text = ''
            echo "!!!!!! This is not meant to happen !!!!!!"
            echo "TODO: explain how to propagate inNixShell"
            exit 1
          '';
        };

        # The actual devshell wrapper script
        envScript = ''
          #!${bashPath}
          # Script that sets-up the environment. Can be both sourced or invoked.
          #
          # Usage: source @out@      # load the environment in the current shell
          # Usage: @out@             # start a bash sub-shell
          # Usage: @out@ <cmd> [...] # run a command in the environment

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

          # TODO: add --help menu?
          # TODO: add --pure functionality?

          if [[ $# = 0 ]]; then
            # Start an interactive shell
            exec "${bashPath}" --rcfile "${bashrc}" --noprofile
          else
            # Start a script
            source "${bashrc}"
            exec -- "$@"
          fi
        '';

        passAsFile = [ "buildScript" "envScript" ];
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
        # bring in the dependencies on `nix-build`
        args = [ "-ec" "${coreutils}/bin/ln -s ${devShellBin} $out" ];

        # $stdenv/setup is loaded by nix-shell during startup.
        # https://github.com/nixos/nix/blob/377345e26f1ac4bbc87bb21debcc52a1d03230aa/src/nix-build/nix-build.cc#L429-L432
        stdenv = writeTextFile {
          name = "devshell-stdenv";
          destination = "/setup";
          text = ''
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
          unset builder name stdenv system out
          unset shellHook
          # Flakes stuff
          unset dontAddDisableDepTrack
          unset outputs

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

  resolveKey = key:
    let
      attrs = builtins.filter builtins.isString (builtins.split "\\." key);
    in
    builtins.foldl' (sum: attr: sum.${attr}) pkgs attrs
  ;

  # Build the devshell from pure JSON-like data
  fromData = data:
    mkDevShell (data // {
      packages = map resolveKey (data.packages or [ ]);
    });

  importTOML = path:
    let
      data = builtins.fromTOML (builtins.readFile path);
    in
    (data.main or { }) // (builtins.removeAttrs data [ "main" ]);

  # Build the devshell from a TOML declaration
  fromTOML = path:
    fromData (importTOML path);
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
