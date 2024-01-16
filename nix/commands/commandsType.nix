{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
}:
with pkgs.lib;
with builtins;
let
  inherit (import ./types.nix { inherit pkgs; })
    commandsFlatType
    commandsNestedType
    resolveKey
    strOrPackage
    ;
in
rec {
  mergeDefs = loc: defs:
    let
      t1 = commandsFlatType;
      t2 = commandsNestedType;
      defsFlat = t1.merge loc (map (d: d // { value = if isList d.value then d.value else [ ]; }) defs);
      defsNested = t2.merge loc (map (d: d // { value = if !(isList d.value) then d.value else { }; }) defs);
    in
    { inherit defsFlat defsNested; };

  extractHelp = arg: if isList arg then head arg else null;

  # Fallback to the package pname if the name is unset
  resolveName = cmd:
    if cmd.name == null then
      cmd.package.pname or (parseDrvName cmd.package.name).name
    else
      cmd.name;

  flattenNonAttrsOrElse = config: alternative:
    if !(isAttrs config) || isDerivation config then
      let
        value = pipe config [
          (x: if isList x then last x else x)
          (x: if strOrPackage.check x then resolveKey x else x)
        ];
        help = extractHelp config;
      in
      [{
        name = resolveName value;
        inherit help;
        ${if isString value then "command" else "package"} = value;
      }]
    else alternative;

  unknownFileName = "<unknown>";

  normalizeCommandsFlat_ = { file ? unknownFileName, loc ? [ ], arg ? [ ] }:
    pipe arg [
      (value: (mergeDefs loc [{ inherit file value; }]).defsFlat)
      (map (config: flattenNonAttrsOrElse config config))
      flatten
      (map (value: { inherit file; value = [ value ]; }))
      (commandsFlatType.merge loc)
    ];

  highlyUnlikelyAttrName = "adjd-laso-msle-copq-pcod";

  collectLeaves = attrs:
    pipe attrs [
      (mapAttrsRecursiveCond (attrs: !(isDerivation attrs))
        (path: value: { "${highlyUnlikelyAttrName}" = { inherit path; inherit value; }; })
      )
      (collect (hasAttr highlyUnlikelyAttrName))
      (map (x: x.${highlyUnlikelyAttrName}))
    ];


  normalizeCommandsNested_ = { file ? unknownFileName, loc ? [ ], arg ? { } }:
    pipe arg [
      # typecheck and augment configs with missing attributes (if a config is an attrset)
      (value: (mergeDefs loc [{ inherit file value; }]).defsNested)
      (mapAttrsToList
        (category: map (config: (map (x: x // { inherit category; })) (
          (flattenNonAttrsOrElse config) (
            # a nestedOptionsType at this point has all attributes due to augmentation
            if config?packages then
              let
                inherit (config) packages commands helps prefixes exposes;

                mkCommands = forPackages:
                  pipe (collectLeaves (if forPackages then packages else commands)) [
                    (map (leaf:
                      let
                        value = pipe leaf.value [
                          (x: if isList x then last x else x)
                          (x: if forPackages && strOrPackage.check x then resolveKey x else x)
                        ];

                        path = leaf.path;

                        name = concatStringsSep "." path;

                        help =
                          if isList leaf.value then
                            head leaf.value
                          else
                            attrByPath path
                              (
                                if isDerivation value then
                                  value.meta.description or null
                                else config.help or null
                              )
                              helps;

                        prefix = attrByPath path (config.prefix or "") prefixes;

                        expose = attrByPath path (config.expose or (!forPackages)) exposes;
                      in
                      {
                        "${if forPackages then "package" else "command"}" = value;
                        inherit name prefix help category expose;
                      }))
                  ];
              in
              (mkCommands true) ++ (mkCommands false)
            else [ config ]
          )
        ))))
      flatten
      (map (value: { inherit file; value = [ value ]; }))
      (commandsFlatType.merge loc)
    ];

  normalizeCommandsNested = arg: normalizeCommandsNested_ { inherit arg; };

  commandsType =
    let
      t1 = commandsFlatType;
      t2 = commandsNestedType;
      either = types.either t1 t2;
    in
    either // rec {
      name = "commandsType";
      description = "(${t1.description}) or (${t2.description})";
      merge = loc: defs:
        let
          inherit (mergeDefs loc defs) defsFlat defsNested;
          defsFlatNormalized = normalizeCommandsFlat_ { arg = defsFlat; inherit loc; };
          defsNestedNormalized = normalizeCommandsNested_ { arg = defsNested; inherit loc; };
          defsMerged = defsFlatNormalized ++ defsNestedNormalized;
        in
        defsMerged;
      getSubOptions = prefix: {
        "${t1.name}" = t1.getSubOptions prefix;
        "${t2.name}" = t2.getSubOptions prefix;
      };
    };
}
