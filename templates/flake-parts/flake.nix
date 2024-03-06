{
  description = "virtual environments";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs =
    inputs@{
      self,
      flake-parts,
      devshell,
      nixpkgs,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devshell.flakeModule ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          devshells.default = (
            { extraModulesPath, ... }@args:
            {
              # `extraModulesPath` provides access to additional modules that are
              # not included in the standard devshell modules list.
              #
              # Please see https://numtide.github.io/devshell/extending.html for
              # documentation on consuming extra modules, and see
              # https://github.com/numtide/devshell/tree/main/extra for the
              # extra modules that are currently available.
              imports = [ "${extraModulesPath}/git/hooks.nix" ];

              git.hooks.enable = false;
              git.hooks.pre-commit.text = ''
                echo 1>&2 'time to implement a pre-commit hook!'
                exit 1
              '';
            }
          );
        };
    };
}
