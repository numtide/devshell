final: prev:
{
  devshell = prev.callPackage ./go/devshell { };
  mkDevShell = prev.callPackage ./. { };
}
