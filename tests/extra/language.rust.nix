{ pkgs, devshell, runTest }:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/rust.nix ];
        devshell.name = "language-rust-simple";
      };
    in
    runTest "simple" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has a rust compiler
      type -p rustc
    '';
}
