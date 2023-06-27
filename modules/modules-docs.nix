# MIT - Copyright (c) 2017-2019 Robert Helgesson and Home Manager contributors.
#
# This is an adapted version of the original https://gitlab.com/rycee/nmd/
{ lib, pkgs, options, config, modulesPath, ... }:
with lib;
let
  cfg = config.modules-docs;

  # Generate some meta data for a list of packages. This is what
  # `relatedPackages` option of `mkOption` lib/options.nix influences.
  #
  # Each element of `relatedPackages` can be either
  # - a string:   that will be interpreted as an attribute name from `pkgs`,
  # - a list:     that will be interpreted as an attribute path from `pkgs`,
  # - an attrset: that can specify `name`, `path`, `package`, `comment`
  #   (either of `name`, `path` is required, the rest are optional).
  mkRelatedPackages =
    let
      unpack = p:
        if isString p then
          { name = p; }
        else if isList p then
          { path = p; }
        else
          p;

      repack = args:
        let
          name = args.name or (concatStringsSep "." args.path);
          path = args.path or [ args.name ];
          pkg = args.package or (
            let
              bail = throw "Invalid package attribute path '${toString path}'";
            in
            attrByPath path bail pkgs
          );
        in
        {
          attrName = name;
          packageName = pkg.meta.name;
          available = pkg.meta.available;
        } // optionalAttrs (pkg.meta ? description) {
          inherit (pkg.meta) description;
        } // optionalAttrs (pkg.meta ? longDescription) {
          inherit (pkg.meta) longDescription;
        } // optionalAttrs (args ? comment) { inherit (args) comment; };
    in
    map (p: repack (unpack p));

  # Transforms a module path into a (path, url) tuple where path is relative
  # to the repo root, and URL points to an online view of the module.
  mkDeclaration =
    let
      rootsWithPrefixes = map
        (p: p // { prefix = "${toString p.path}/"; })
        cfg.roots;
    in
    decl:
    let
      root = lib.findFirst
        (x: lib.hasPrefix x.prefix decl)
        null
        rootsWithPrefixes;
    in
    if root == null then
    # We need to strip references to /nix/store/* from the options or
    # else the build will fail.
      { path = removePrefix "${builtins.storeDir}/" decl; url = ""; }
    else
      rec {
        path = removePrefix root.prefix decl;
        url = "${root.url}/tree/${root.branch}/${path}";
      };

  # Sort modules and put "enable" and "package" declarations first.
  moduleDocCompare = a: b:
    let
      isEnable = lib.hasPrefix "enable";
      isPackage = lib.hasPrefix "package";
      compareWithPrio = pred: cmp: splitByAndCompare pred compare cmp;
      moduleCmp = compareWithPrio isEnable (compareWithPrio isPackage compare);
    in
    compareLists moduleCmp a.loc b.loc < 0;

  # Replace functions by the string <function>
  substFunction = x:
    if builtins.isAttrs x then
      mapAttrs (name: substFunction) x
    else if builtins.isList x then
      map substFunction x
    else if isFunction x then
      "<function>"
    else
      x;

  cleanUpOption = opt:
    let
      applyOnAttr = n: f: optionalAttrs (hasAttr n opt) { ${n} = f opt.${n}; };
    in
    opt
    // applyOnAttr "declarations" (map mkDeclaration)
    // applyOnAttr "example" substFunction
    // applyOnAttr "default" substFunction
    // applyOnAttr "type" substFunction
    // applyOnAttr "relatedPackages" mkRelatedPackages;

  optionsDocs = map cleanUpOption (
    sort
      moduleDocCompare
      (
        filter
          (opt: opt.visible && !opt.internal)
          (optionAttrSetToDocList options)
      )
  );

  # TODO: display values like TOML instead.
  toMarkdown = optionsDocs:
    let
      # TODO: handle opt.relatedPackages. What is it for?
      optToMd = opt:
        ''
          ## `${opt.name}`

        ''
        + (lib.optionalString opt.internal "\n**internal**\n")
        + opt.description + "\n"
        + (lib.optionalString (opt ? default && opt.default != null) ''

          **Default value**:
          ```nix
          ${
            # When defaultText is set on the module, we only get back a
            # string here and defaultText has disappeared. Re-hydrate that
            # knowledge by looking at the type.
            if builtins.isString opt.default && !(lib.hasPrefix "string" opt.type) then
              # If it's a defaultText, assume it's already formatted as nix
              # code.
              opt.default
            else
              builtins.toJSON opt.default
          }
          ```

        '')
        + ''

          **Type**: ${opt.type}
        ''
        + (lib.optionalString (opt ? example) ''

          **Example value**:
          ```nix
          ${builtins.toJSON opt.example}
          ```

        '')
        + ''

          Declared in:
        ''
        + (
          lib.concatStringsSep
            "\n"
            (map
              (decl: "* [${decl.path}](${decl.url})")
              opt.declarations
            )
        )
        + "\n"
      ;
    in
    concatStringsSep "\n" (map optToMd optionsDocs);
in
{
  options.modules-docs = {
    roots = mkOption {
      internal = true;
      type = types.listOf types.attrs;
      description = ''
        Add to this list for each new module root. The attr should have path,
        url and branch attributes (TODO: convert to submodule).
      '';
    };

    data = mkOption {
      visible = false;
      type = types.listOf types.attrs;
      description = ''
        Contains a list of each module option, nicely split out for
        consumption.
      '';
    };

    markdown = mkOption {
      visible = false;
      type = types.package;
      description = ''
        Modules documentation rendered to markdown.
      '';
    };
  };

  config.modules-docs = {
    data = optionsDocs;
    markdown = pkgs.writeText "modules-docs.md" (toMarkdown optionsDocs);
  };
}
