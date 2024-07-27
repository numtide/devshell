{
  pkgs,
  devshell,
  runTest,
}:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/perl.nix ];
        devshell.name = "language-perl-simple";
      };
    in
    runTest "simple" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has a Perl interpreter
      type -p perl
    '';
}
