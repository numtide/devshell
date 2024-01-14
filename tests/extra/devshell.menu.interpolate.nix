{ pkgs, devshell, runTest }:
{
  interpolate =
    let
      shell = devshell.mkShell {
        devshell.menu.interpolate = true;
        commands = [
          { package = "hello"; help = "hello from '$PRJ_ROOT'!"; }
          { package = "jq"; help = ''jq from '\$PRJ_ROOT'!''; }
        ];
      };
    in
    runTest "interpolate" { } ''
      # Check interpolation is enabled
      cat ${shell}/bin/menu | grep '<<DEVSHELL_MENU'
      
      # Check escaped variable
      eval ${shell}/bin/menu | grep '\$PRJ_ROOT'
    '';
}
