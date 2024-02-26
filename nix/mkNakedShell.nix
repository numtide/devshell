{ bashInteractive
, coreutils
, stdenv
, writeTextFile
}:
let
  bashPath = "${bashInteractive}/bin/bash";
  nakedStdenv = writeTextFile {
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
  inherit name;

  system = stdenv.hostPlatform.system;

  # `nix develop` actually checks and uses builder. And it must be bash.
  builder = bashPath;

  # Bring in the dependencies on `nix-build`
  args = [ "-ec" "${coreutils}/bin/ln -s ${profile} $out; exit 0" ];

  # $stdenv/setup is loaded by nix-shell during startup.
  # https://github.com/nixos/nix/blob/377345e26f1ac4bbc87bb21debcc52a1d03230aa/src/nix-build/nix-build.cc#L429-L432
  stdenv = nakedStdenv;

  # The shellHook is loaded directly by `nix develop`. But nix-shell
  # requires that other trampoline.
  shellHook = ''
    # Remove all the unnecessary noise that is set by the build env
    unset NIX_BUILD_TOP NIX_BUILD_CORES NIX_STORE
    unset TEMP TEMPDIR TMP TMPDIR
    # $name variable is preserved to keep it compatible with pure shell https://github.com/sindresorhus/pure/blob/47c0c881f0e7cfdb5eaccd335f52ad17b897c060/pure.zsh#L235
    unset builder out shellHook stdenv system
    # Flakes stuff
    unset dontAddDisableDepTrack outputs

    # For `nix develop`. We get /noshell on Linux and /sbin/nologin on macOS.
    if [[ "$SHELL" == "/noshell" || "$SHELL" == "/sbin/nologin" ]]; then
      export SHELL=${bashPath}
    fi

    # Load the environment
    source "${profile}/env.bash"
  '';
}) // { inherit meta passthru; } // passthru
