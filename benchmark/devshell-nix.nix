{
  system ? builtins.currentSystem,
}:
let
  devshell = import ../. { inherit system; };
in
devshell.mkShell { }
