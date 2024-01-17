{ pkgs, devshell, runTest }:
{
  interpolate =
    let
      shell = devshell.mkShell {
        devshell.menu.interpolate = true;
        commands = [
          { prefix = "hello"; help = ''hello from "$PRJ_ROOT"!''; }
          { prefix = "hola"; help = ''hola from '\$PRJ_ROOT'!''; }
        ];
      };
    in
    runTest "interpolate" { } ''
      # Check interpolation is enabled
      eval ${shell}/bin/menu | grep "hello from \"$PRJ_ROOT\"!"
      
      # Check escaped variable
      eval ${shell}/bin/menu | grep 'hola from '\'''$PRJ_ROOT'\'
    '';
}
