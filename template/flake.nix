{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = { devshell, nixpkgs, ... }@inputs: {
    devshell.lib.flakeTOML inputs ./devshell.toml;
  };
}
