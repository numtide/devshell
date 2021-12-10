format: {pkgs, config, lib, ...}: 
let
  yj-args.json = "-jji";
  yj-args.yaml = "-jy";
  yj-args.toml = "-jt";
  yj-args.hcl = "-jc";
  yj-arg = yj-args.${format};
  cfg = config.files.${format};
  type = (pkgs.formats.json {}).type;
  generate = name: value: pkgs.runCommand name {
      nativeBuildInputs = [ pkgs.yj ];
      value = builtins.toJSON value;
      passAsFile = [ "value" ];
    } ''
      cat "$valuePath"| yj ${yj-arg} > "$out"
    '';
  toFile = name: value: {
    source = generate (builtins.baseNameOf name) value;
    git-add = lib.mkIf config.files.git.auto-add true;
  };
in {
  options.files.${format} = lib.mkOption {
    type = lib.types.attrsOf type;
    description = ''
      Create ${format} files with correponding content
    '';
    default = {};
    example."/hello.${format}".greeting = "hello World";
    example."/hellows.${format}".greetings = [ ["Hello World"] ["Ola Mundo" ["Holla Que Tal"]]];
  };
  config.file = lib.mapAttrs toFile cfg;
}
