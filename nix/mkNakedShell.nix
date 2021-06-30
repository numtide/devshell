{ bashInteractive
, coreutils
, system
, writeTextFile
}:
let
  bashPath = "${bashInteractive}/bin/bash";
  _system = system;

  stdenv = writeTextFile {
    name = "naked-stdenv";
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
in
{ name
, # A path to a buildEnv that will be loaded by the shell.
  # We assume that the buildEnv contains an ./env.bash script.
  profile
, meta ? { }
, passthru ? { }
}:
(derivation {
  inherit name system;

  # `nix develop` actually checks and uses builder. And it must be bash.
  builder = bashPath;

  # Bring in the dependencies on `nix-build`
  args = [ "-ec" "${coreutils}/bin/ln -s ${profile} $out; exit 0" ];

  # $stdenv/setup is loaded by nix-shell during startup.
  # https://github.com/nixos/nix/blob/377345e26f1ac4bbc87bb21debcc52a1d03230aa/src/nix-build/nix-build.cc#L429-L432
  stdenv = stdenv;

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

    # Load the environment
    source "${profile}/env.bash"
  '';
}) // { inherit meta passthru; } // passthru
