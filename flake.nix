{
  description = "mkDevShell";

  outputs = { self, nixpkgs }: {
    overlay = import ./overlay.nix;

    defaultApp.x86_64-linux = (import ./shell.nix {
      inNixShell = false;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    }
    ).flakeApp;

    devShell.x86_64-linux = import ./shell.nix {
      inNixShell = true;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };

  };
}
