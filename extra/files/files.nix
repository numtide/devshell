{ pkgs, config, lib, ... }:
let
  files = config.file;
  fileType = (import ./file-type.nix { inherit pkgs config lib; }).fileType;
  chmod = file:
    if file.executable == null then ""
    else if file.executable then "chmod +x $target"
    else "chmod -x $target";
  # Execute this script to update the project's files
  nameToScript = name: builtins.replaceStrings ["/" "."] ["-" "-"] (lib.removePrefix "/" name);
  copy-file = name: file: pkgs.writeShellScriptBin (nameToScript name) ''
    export PATH=${pkgs.coreutils}/bin:$PATH
    out="$(git rev-parse --show-toplevel)"
    realOut="$(realpath -m "$out")"
    target="$(realpath -m "$realOut/${file.target}")"
    mkdir -p "$(dirname "$target")"
    cp --no-preserve=mode,ownership,timestamps "${file.source}" "$target"
    ${chmod file}
  '';
  startups = lib.mapAttrsToList (n: f: 
    let name  = nameToScript n;
    in {
      ${name}.text = ''
        $DEVSHELL_DIR/bin/${name}
      '';
    }) files;
in {
  options.file = lib.mkOption {
    description = "Attribute set of files to create into the project root.";
    default = {};
    type = fileType "<envar>PRJ_ROOT</envar>";
  };
  config.commands = [
    {
      name = "files";
      help = "Regenerate files";
      command = "nix develop --build";
    }
  ];
  config.devshell.packages = lib.mapAttrsToList copy-file files;
  config.devshell.startup = lib.foldAttrs lib.mergeAttrs {} startups;
}
