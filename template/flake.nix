{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = { devshell, nixpkgs }:
    devshell.lib.flakeTOML nixpkgs ./devshell.toml;
}
