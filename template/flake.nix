{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell =
        let inherit (pkgs.devshell) mkShell importTOML;

          pkgs = import nixpkgs {
            inherit system;

            overlays = [ devshell.overlay ];
          };
        in
        mkShell {
          imports = [ (importTOML ./devshell.toml) ];
        };
    });
}
