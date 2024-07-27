{
  pkgs,
  devshell,
  runTest,
}:
pkgs.lib.optionalAttrs (!pkgs.hostPlatform.isDarwin) {
  # Basic test
  language-hare-1 =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/hare.nix ];
        devshell.name = "devshell-1";
      };
    in
    runTest "language-hare-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has a Hare binary
      type -p hare
    '';
  # Test good HAREPATH value
  # TODO: When the nixpkgs input is updated, change hare-ev to hare-png, so
  # that the inclusion of propagatedBuildInputs third-party libraries is also tested.
  language-hare-2 =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/hare.nix ];
        devshell.name = "devshell-2";
        language.hare = {
          thirdPartyLibs = [ pkgs.hareThirdParty.hare-compress ];
          vendoredLibs = [ "./vendor/lib" ];
        };
      };
    in
    runTest "language-hare-2" { } ''
      # Load the devshell
      source ${shell}/env.bash

      die() {
        printf -- '%s\n' "''${*}" 2>&1
        printf -- 'HAREPATH: `%s`\n' ''${HAREPATH//:/ } 2>&1
        exit 1
      }

      # Check for HAREPATH being set
      [[ -n "$HAREPATH" ]] || die "HAREPATH not set"

      # Check for the stdlib being included in HAREPATH
      [[ "$HAREPATH" =~ "src/hare/stdlib" ]] || die 'HAREPATH lacks `stdlib`'

      # Check for hare-ev being included in HAREPATH
      [[ "$HAREPATH" =~ /nix/store/[a-z0-9]{32}-hare-compress-.*/src/hare/third-party ]] \
        || die 'HAREPATH lacks `hare-compress`'

      # Check for ./vendor/lib being included in HAREPATH
      [[ "$HAREPATH" =~ $PWD/vendor/lib ]] || die "HAREPATH lacks \`$PWD/vendor/lib\`"
    '';
}
