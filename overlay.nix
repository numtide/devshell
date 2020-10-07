final: prev:
{
  devshell = prev.callPackage ./devshell { };
  mkDevShell = prev.callPackage ./mkDevShell { };
}
