final: prev:
{
  mkDevShell = prev.callPackage ./. { };
}
