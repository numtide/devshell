{
  pkgs,
  devshell,
  runTest,
}:
{
  # Basic test
  language-ruby-1 =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/ruby.nix ];
        devshell.name = "devshell-1";
      };
    in
    runTest "language-ruby-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has ruby
      type -p ruby

      # Has a GCC compiler
      type -p gcc
    '';
}
