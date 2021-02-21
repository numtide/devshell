{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let shell = import devshell { inherit system; }; in
        shell.mkShell {
          imports = [ (shell.importTOML ./devshell.toml) ];

          commands = [{
            package = devshell.defaultPackage.${system};
            help = "Per project developer environments";
          }];
        };
    });
}
