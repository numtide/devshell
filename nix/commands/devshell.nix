{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
, config ? { }
}:
let
  lib = builtins // pkgs.lib;
in
rec {
  ansi = import ../ansi.nix;

  writeDefaultShellScript = import ../writeDefaultShellScript.nix {
    inherit (pkgs) lib writeTextFile bash;
  };

  devshellMenuCommandName = "menu";

  pad = str: num:
    if num > 0 then
      pad "${str} " (num - 1)
    else
      str;

  resolveName = cmd:
    if cmd.name == null then
      cmd.package.pname or (lib.parseDrvName cmd.package.name).name
    else
      cmd.name;

  commandsMessage = "[[commands]]:";

  # Fill in default options for a command.
  commandToPackage = cmd:
    if cmd.name != devshellMenuCommandName && cmd.command == null && cmd.package == null then null
    else
      assert lib.assertMsg (cmd.command == null || cmd.name != cmd.command) "${commandsMessage} in ${lib.generators.toPretty {} cmd}, ${toString cmd.name} cannot be set to both the `name` and the `command` attributes. Did you mean to use the `package` attribute?";
      assert lib.assertMsg ((cmd.package != null && cmd.command == null) || (cmd.command != null && cmd.command != "" && cmd.package == null)) "${commandsMessage} ${lib.generators.toPretty {} cmd} expected either a non-empty command or a package attribute, not both.";
      if cmd.package == null
      then
        writeDefaultShellScript
          {
            name = cmd.name;
            text = cmd.command;
            binPrefix = true;
          }
      else if !cmd.expose
      then null
      else cmd.package;

  commandsToMenu = menuConfig: cmds:
    let
      cleanName = { name, package, ... }@cmd:
        if
          cmd.package == null && (cmd.name != devshellMenuCommandName && cmd.command == null)
          && (cmd.prefix != "" || (cmd.name != null && cmd.name != ""))
          && cmd.help != null
        then
          cmd // {
            name = "${
                if cmd.prefix != null then cmd.prefix else ""
              }${
                if cmd.name != null then cmd.name else ""
              }";
          }
        else
          assert lib.assertMsg (cmd.name != null || cmd.package != null) "${commandsMessage} some command is missing a `name`, a `prefix`, and a `package` attributes.";
          let
            name = lib.pipe cmd [
              resolveName
              (x: if x != null && lib.hasInfix " " x then "'${x}'" else x)
              (x: "${cmd.prefix}${x}")
            ];

            help =
              if cmd.help == null then
                cmd.package.meta.description or ""
              else
                cmd.help;
          in
          cmd // {
            inherit name help;
          };

      commands = map cleanName cmds;

      commandLengths =
        map ({ name, ... }: lib.stringLength name) commands;

      maxCommandLength =
        lib.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths
      ;

      commandCategories = lib.unique (
        (lib.zipAttrsWithNames [ "category" ] (_: vs: vs) commands).category
      );

      commandByCategoriesSorted =
        lib.attrValues (lib.genAttrs
          commandCategories
          (category: lib.nameValuePair category (lib.sort
            (a: b: a.name < b.name)
            (lib.filter (x: x.category == category) commands)
          ))
        );

      opCat = kv:
        let
          category = kv.name;
          cmd = kv.value;
          opCmd = { name, help, interpolate, ... }:
            let
              len = maxCommandLength - (lib.stringLength name);

              nameWidth = toString maxCommandLength;
              helpWidth = toString (config.devshell.menu.width - (maxCommandLength + 5));
              helpHeight = toString 100;

              processHelp = x:
                if (if interpolate != null then interpolate else menuConfig.interpolate)
                then ''\'' + "\n" +
                  ''
                    "$(
                    cat << EOF
                    ${x}
                    EOF
                    )"
                  ''
                else lib.escapeShellArg x;

              highlyUnlikelyName = "ABDH_OKKD_VOAP_DOEE_PJGD";

              command = ''
                ${highlyUnlikelyName}=${
                  if help == null || help == ""
                  then ""
                  else processHelp help
                }
                ${lib.getExe pkgs.perl} ${./scripts/formatCommand.pl} '${toString nameWidth}' '${helpWidth}' '${helpHeight}' '${name}' "''$${highlyUnlikelyName}"
              '';
            in
            command;
          commandsColumns = lib.concatMapStringsSep "\n" opCmd cmd;
        in
        ''
          printf '\n${ansi.bold}[${category}]${ansi.reset}\n\n'
          
          ${commandsColumns}
        '';
    in
    ''
      {
        export LC_ALL="C"
        ${lib.concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n"}
      }
    '';
}
