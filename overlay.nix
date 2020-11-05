final: prev:
{
  devshell = prev.callPackage ./devshell.nix { };
  mkDevShell = prev.callPackage ./mkDevShell { };
  flake-env = prev.callPackage ./flake-env.nix { };
}
