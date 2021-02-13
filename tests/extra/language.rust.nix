{ pkgs, devshell, runTest }:
{
  # Basic test
  simple =
    let
      shell = devshell.mkShell {
        imports = [ ../../modules_extra/language/rust.nix ];
        devshell.name = "language-rust-simple";
      };
    in
    runTest "simple" { } ''
      # Load the devshell
      source ${shell}

      # Has a rust compiler
      type -p rustc
    '';
}
