{ pkgs, devshell }:
{
  modules-docs-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "modules-docs";
      };
    in
    pkgs.runCommand "modules-docs-1" { } ''
      # The Markdown gets generated and is a derivation
      [[ ${toString shell.config.modules-docs.markdown} == /nix/store/* ]]

      echo "Markdown has been generated"

      touch $out
    '';
}
