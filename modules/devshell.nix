{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.devshell;

  ansi = import ../nix/ansi.nix;

  bashBin = "${cfg.bashPackage}/bin";
  bashPath = "${cfg.bashPackage}/bin/bash";

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  inherit (import ../nix/commands/devshell.nix { inherit pkgs; }) devshellMenuCommandName;

  # Use this to define a flake app for the environment.
  mkFlakeApp = bin: {
    type = "app";
    program = "${bin}";
  };

  mkSetupHook = rc:
    pkgs.stdenvNoCC.mkDerivation {
      name = "devshell-setup-hook";
      setupHook = pkgs.writeText "devshell-setup-hook.sh" ''
        source ${rc}
      '';
      dontUnpack = true;
      dontBuild = true;
      dontInstall = true;
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
    if [[ -n ''${IN_NIX_SHELL:-} || ''${DIRENV_IN_ENVRC:-} = 1 ]]; then
      # We know that PWD is always the current directory in these contexts
      PRJ_ROOT=$PWD
    elif [[ -z ''${PRJ_ROOT:-} ]]; then
      ${lib.optionalString (cfg.prj_root_fallback != null) cfg.prj_root_fallback}

      if [[ -z "''${PRJ_ROOT:-}" ]]; then
        echo "ERROR: please set the PRJ_ROOT env var to point to the project root" >&2
        return 1
      fi
    fi

    export PRJ_ROOT

    # Expose the folder that contains the assembled environment.
    export DEVSHELL_DIR=@DEVSHELL_DIR@

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


  # This is our entrypoint script.
  entrypoint = pkgs.writeScript "${cfg.name}-entrypoint" ''
    #!${bashPath}
    # Script that sets-up the environment. Can be both sourced or invoked.

    export DEVSHELL_DIR=@DEVSHELL_DIR@

    # If the file is sourced, skip all of the rest and just source the env
    # script.
    if (return 0) &>/dev/null; then
      source "$DEVSHELL_DIR/env.bash"
      return
    fi

    # Be strict!
    set -euo pipefail

    while (( "$#" > 0 )); do
      case "$1" in
        -h|--help)
          help=1
          ;;
        --pure)
          pure=1
          ;;
        --prj-root)
          if (( "$#" < 2 )); then
            echo 1>&2 '${cfg.name}: missing required argument to --prj-root'
            exit 1
          fi

          PRJ_ROOT="$2"

          shift
          ;;
        --env-bin)
          if (( "$#" < 2 )); then
            echo 1>&2 '${cfg.name}: missing required argument to --env-bin'
            exit 1
          fi

          env_bin="$2"

          shift
          ;;
        --)
          shift
          break
          ;;
        *)
          break
          ;;
      esac

      shift
    done

    if [[ -n "''${help:-}" ]]; then
      cat <<USAGE
    Usage: ${cfg.name}
      $0 -h | --help          # show this help
      $0 [--pure]             # start a bash sub-shell
      $0 [--pure] <cmd> [...] # run a command in the environment

    Options:
      * --pure            : execute the script in a clean environment
      * --prj-root <path> : set the project root (\$PRJ_ROOT)
      * --env-bin <path>  : path to the env executable (default: /usr/bin/env)
    USAGE
      exit
    fi

    if (( "$#" == 0 )); then
      # Start an interactive shell
      set -- ${lib.escapeShellArg bashPath} --rcfile "$DEVSHELL_DIR/env.bash" --noprofile
    fi

    if [[ -n "''${pure:-}" ]]; then
      # re-execute the script in a clean environment.
      # note that the `--` in between `"$0"` and `"$@"` will immediately
      # short-circuit options processing on the second pass through this
      # script, in case we get something like:
      #   <entrypoint> --pure -- --pure <cmd>
      set -- "''${env_bin:-/usr/bin/env}" -i -- ''${HOME:+"HOME=''${HOME:-}"} ''${PRJ_ROOT:+"PRJ_ROOT=''${PRJ_ROOT:-}"} "$0" -- "$@"
    else
      # Start a script
      source "$DEVSHELL_DIR/env.bash"
    fi

    exec -- "$@"
  '';

  # Builds the DEVSHELL_DIR with all the dependencies
  devshell_dir = pkgs.buildEnv {
    name = "devshell-dir";
    paths = cfg.packages;
    postBuild = ''
      substitute ${envBash} $out/env.bash --subst-var-by DEVSHELL_DIR $out
      substitute ${entrypoint} $out/entrypoint --subst-var-by DEVSHELL_DIR $out
      chmod +x $out/entrypoint
    '';
  };

  # Returns a list of all the input derivation ... for a derivation.
  inputsOf = drv:
    (drv.buildInputs or [ ]) ++
    (drv.nativeBuildInputs or [ ]) ++
    (drv.propagatedBuildInputs or [ ]) ++
    (drv.propagatedNativeBuildInputs or [ ])
  ;

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

    package = mkOption {
      internal = true;
      type = types.package;
      description = ''
        This package contains the DEVSHELL_DIR
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
        {202}🔨 Welcome to ${cfg.name}{reset}
        $(type -p ${devshellMenuCommandName} &>/dev/null && ${devshellMenuCommandName})
      '';
      apply = replaceStrings
        (map (key: "{${key}}") (attrNames ansi))
        (attrValues ansi);
      description = ''
        Message Of The Day.

        This is the welcome message that is being printed when the user opens
        the shell.

        You may use any valid ansi color from the 8-bit ansi color table. For example, to use a green color you would use something like {106}. You may also use {bold}, {italic}, {underline}. Use {reset} to turn off all attributes.
      '';
    };

    load_profiles = mkEnableOption "load etc/profiles.d/*.sh in the shell";

    name = mkOption {
      type = types.str;
      default = "devshell";
      description = ''
        Name of the shell environment. It usually maps to the project name.
      '';
    };

    meta = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Metadata, such as 'meta.description'. Can be useful as metadata for downstream tooling.
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

    packagesFrom = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = ''
        Add all the build dependencies from the listed packages to the
        environment.
      '';
    };

    shell = mkOption {
      internal = true;
      type = types.package;
      description = "TODO";
    };

    prj_root_fallback = mkOption {
      type =
        let
          envType = options.env.type.nestedTypes.elemType;
          coerceFunc = value: { inherit value; };
        in
        types.nullOr (types.coercedTo types.nonEmptyStr coerceFunc envType);
      apply = x: if x == null then x else x // { name = "PRJ_ROOT"; };
      default = { eval = "$PWD"; };
      example = lib.literalExpression ''
        {
          # Use the top-level directory of the working tree
          eval = "$(git rev-parse --show-toplevel)";
        };
      '';
      description = ''
        If IN_NIX_SHELL is nonempty, or DIRENV_IN_ENVRC is set to '1', then
        PRJ_ROOT is set to the value of PWD.

        This option specifies the path to use as the value of PRJ_ROOT in case
        IN_NIX_SHELL is empty or unset and DIRENV_IN_ENVRC is any value other
        than '1'.

        Set this to null to force PRJ_ROOT to be defined at runtime (except if
        IN_NIX_SHELL or DIRENV_IN_ENVRC are defined as described above).

        Otherwise, you can set this to a string representing the desired
        default path, or to a submodule of the same type valid in the 'env'
        options list (except that the 'name' field is ignored).
      '';
    };

    menu = mkOption {
      type = types.submodule {
        options.interpolate = mkEnableOption "interpolation in the devshell menu";
      };
      default = { };
      description = ''
        Controls devshell menu
      '';
      example = literalExpression ''
        {
          interpolate = true;
        }
      '';
    };
  };

  config.devshell = {
    package = devshell_dir;

    packages = foldl' (sum: drv: sum ++ (inputsOf drv)) [ ] cfg.packagesFrom;

    startup = {
      motd = noDepEntry ''
        __devshell-motd() {
          cat <<DEVSHELL_PROMPT
        ${cfg.motd}
        DEVSHELL_PROMPT
        }

        if [[ ''${DEVSHELL_NO_MOTD:-} = 1 ]]; then
          # Skip if that env var is set
          :
        elif [[ ''${DIRENV_IN_ENVRC:-} = 1 ]]; then
          # Print the motd in direnv
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
    } // (optionalAttrs cfg.load_profiles {
      load_profiles = lib.noDepEntry ''
        # Load installed profiles
        for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
          # If that folder doesn't exist, bash loves to return the whole glob
          [[ -f "$file" ]] && source "$file"
        done
      '';
    });

    interactive = {
      PS1_util = noDepEntry ''
        if [[ -n "''${PRJ_ROOT:-}" ]]; then
          # Print the path relative to $PRJ_ROOT
          rel_root() {
            local path
            path=$(${pkgs.coreutils}/bin/realpath --relative-to "$PRJ_ROOT" "$PWD")
            if [[ $path != . ]]; then
              echo " $path "
            fi
          }
        else
          # If PRJ_ROOT is unset, print only the current directory name
          rel_root() {
            echo " \W "
          }
        fi
      '';

      # Set a cool PS1
      PS1 = stringAfter [ "PS1_util" ] (lib.mkDefault ''
        __set_prompt() {
          PS1='\[\033[38;5;202m\][${cfg.name}]$(rel_root)\$\[\033[0m\] '
        }
        # Only set the prompt when entering a nix shell, since nix shells
        # always reset to plain bash, otherwise respect the user's preferences
        [[ -n "''${IN_NIX_SHELL:-}" ]] && __set_prompt
        unset -f __set_prompt
      '');
    };

    # Use a naked derivation to limit the amount of noise passed to nix-shell.
    shell = mkNakedShell {
      name = strings.sanitizeDerivationName cfg.name;
      inherit (cfg) meta;
      profile = cfg.package;
      passthru = {
        inherit config;
        flakeApp = mkFlakeApp "${devshell_dir}/entrypoint";
        hook = mkSetupHook "${devshell_dir}/env.bash";
        inherit (config._module.args) pkgs;
      };
    };
  };
}
