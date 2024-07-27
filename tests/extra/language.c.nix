{
  pkgs,
  devshell,
  runTest,
}:
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
  # Test good LD_LIBRARY_PATH value
  language-c-2 =
    let
      shell = devshell.mkShell {
        imports = [ ../../extra/language/c.nix ];
        devshell.name = "devshell-2";
        language.c.libraries = [ pkgs.openssl ];
      };
    in
    runTest "language-c-2" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # LD_LIBRARY_PATH is evaluated correctly
      [[ ! "$LD_LIBRARY_PATH" =~ "DEVSHELL_DIR" ]]
    '';
}
