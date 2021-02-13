{ pkgs, devshell, runTest }:
{
  # Basic test
  language-c-1 =
    let
      shell = devshell.mkShell {
        imports = [ ../../modules_extra/language/c.nix ];
        devshell.name = "devshell-1";
      };
    in
    runTest "language-c-1" { } ''
      # Load the devshell
      source ${shell}


      # Has a C compiler
      type -p clang
    '';
}
