{ pkgs, devshell, runTest }:
{
  interpolate =
    let
      shell = devshell.mkShell {
        devshell.menu = {
          interpolate = true;
          width = 200;
        };
        commands.scripts = [
          { prefix = "hello"; help = ''hello from "$PRJ_ROOT"!''; }
          { prefix = "hola"; help = ''hola from '\$PRJ_ROOT'!''; }
          { prefix = "hallo"; help = ''hallo from "$PRJ_ROOT"!''; interpolate = false; }
        ];
      };
    in
    runTest "interpolate" { } ''
      # Check interpolation is enabled
      ( eval ${shell}/bin/menu | grep "hello from \"$PRJ_ROOT\"!" )
      
      # Check escaped variable
      ( eval ${shell}/bin/menu | grep 'hola from '\'''$PRJ_ROOT'\' )

      # Check non-interpolated variable
      ( eval ${shell}/bin/menu | grep 'hallo from "$PRJ_ROOT"!' )
    '';
}
