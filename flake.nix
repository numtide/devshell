{
  description = "mkDevShell";

  outputs = { self, nixpkgs }:
    let
      devshell = import ./shell.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };
    in
    {
      overlay = import ./overlay.nix;
      defaultApp.x86_64-linux = devshell.flakeApp;
      devShell.x86_64-linux = devshell;
    };
}
