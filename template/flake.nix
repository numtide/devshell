{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = { self, devshell, nixpkgs }:
    devshell.lib.flakeTOML nixpkgs ./devshell.toml;
}
