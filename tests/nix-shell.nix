{ pkgs, devshell }:
let
  # A magic incantation to get the .drv path of a derivation
  getDrvPath = drv:
    let
      context = builtins.getContext drv.outPath;
      drvPath = builtins.head (builtins.attrNames context);
      drvPathWithContext = builtins.appendContext drvPath { "${drvPath}" = { path = true; }; };
    in
    drvPathWithContext;
in
{
  nix-shell-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "nix-shell-1";
      };
    in
    pkgs.runCommand "nix-shell-1"
      {
        buildInputs = [ pkgs.nixUnstable ];
      }
      ''
        # Setup the environment for nix-shell
        mkdir home
        export HOME=$PWD/home

        ls -la /nix/

        # Pass the .drv to nix-shell
        nix-shell --store $HOME/nix --readonly-mode --option sandbox false ${getDrvPath shell} --run "echo OK"

        touch $out
      '';

}
