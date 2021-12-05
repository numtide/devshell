{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";

  outputs = { devshell, ... }: devshell.lib.fromTOML ./devshell.toml;
}
