# Import this overlay in your project to add devshell and mkDevShell
final: prev:
{
  devshell = import ./. { nixpkgs = final; };
}
