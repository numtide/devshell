# Import this overlay in your project to add devshell
final: prev:
{
  devshell = import ./. { nixpkgs = final; };
}
