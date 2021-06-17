{ pkgs, devshell, runTest }:
{
  # Basic test
  language-c-1 =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/c.nix ];
        devshell.name = "devshell-1";
      };
    in
    runTest "language-c-1" { } ''
      # Load the devshell
      source ${shell}/env.bash


      # Has a C compiler
      type -p clang
    '';
}
