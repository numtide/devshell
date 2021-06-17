{ pkgs, devshell, runTest }:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/locale.nix ];
        devshell.name = "locale-simple";
      };
    in
    runTest "simple" { } ''
      # Assume that LOCAL_ARCHIVE is not set before
      assert -z "$LOCALE_ARCHIVE"

      # Load the devshell
      source ${shell}/env.bash

      # Sets LOCALE_ARCHIVE
      if [[ $OSTYPE == linux-gnu ]]; then
        assert -n "$LOCALE_ARCHIVE"
      else
        assert -z "$LOCALE_ARCHIVE"
      fi
    '';
}
