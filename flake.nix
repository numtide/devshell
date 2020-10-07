{
  description = "mkDevShell";

  outputs = { self }:
    let
      # nixpkgs is only used for development. Don't add it to the flake.lock.
      gitRev = "500d695aac9ea67195812f309890a911fbc96bda";
      nixpkgs = builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${gitRev}.tar.gz";
        sha256 = "sha256-ya3rCWKDbPWMVsh89/Z1mCJ9HFa5/DKdjcgcKkWB1xs=";
      };

      # Real developers use Linux for development :-p
      system = "x86_64-linux";

      pkgs = import ./. {
        inherit nixpkgs system;
      };
    in
    {
      # Import this overlay into your instance of nixpkgs
      overlay = import ./overlay.nix;

      ## Only use for development
      defaultPackage.${system} = pkgs.devshell;
      devShell.${system} = import ./shell.nix { inherit pkgs; };
    };
}
