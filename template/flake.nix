{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = { devshell, nixpkgs, ... }@inputs: {
    devShell = devshell.lib.flakeTOML inputs ./devshell.toml;
  };
}
