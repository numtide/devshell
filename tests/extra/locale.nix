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
      source ${shell}

      # Sets LOCALE_ARCHIVE
      assert -n "$LOCALE_ARCHIVE"
    '';
}
