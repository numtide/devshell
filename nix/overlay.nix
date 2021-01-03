final: prev:
{
  devshell = prev.callPackage ./devshell.nix { };
  mkDevShell = prev.callPackage ./mkDevShell.nix { };
}
