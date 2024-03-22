{ pkgs, devshell, runTest }:
{
  nested =
    let
      shell = devshell.mkShell {
        devshell.name = "nested-commands-test";
        commands = (import ../../nix/commands/examples.nix { inherit pkgs; }).nested;
      };
    in
    runTest "nested" { } ''
      # Load the devshell
      source ${shell}/env.bash

      type -p python3

      # Has hyperfine
      # Has no yq
      if [[ -z "$(type -p hyperfine)" ]]; then
        echo "OK"
      else
        echo "Error! Has hyperfine"
      fi

      # Has no yq
      if [[ -z "$(type -p yq)" ]]; then
        echo "OK"
      else
        echo "Error! Has yq"
      fi
    '';

  flat =
    let
      shell = devshell.mkShell {
        devshell.name = "flat-commands-test";
        commands = (import ../../nix/commands/examples.nix { inherit pkgs; }).flat;
      };
    in
    runTest "flat" { } ''
      # Load the devshell
      source ${shell}/env.bash

      # Has yarn
      type -p yarn

      # Has hello
      type -p hello

      # Has black
      type -p black
    '';
}
