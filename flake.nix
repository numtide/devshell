{
  description = "devshell";

  outputs = { self }:
    let
      # Real developers use Linux for development :-p
      system = "x86_64-linux";
      pkgs = import ./nix { inherit system; };
    in
    {
      # Import this overlay into your instance of nixpkgs
      overlay = import ./nix/overlay.nix;

      ## Only use for development
      defaultPackage.${system} = pkgs.devshell;
      devShell.${system} = import ./shell.nix { inherit pkgs; };
    };
}
