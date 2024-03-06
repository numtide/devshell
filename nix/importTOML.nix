let
  importTOML =
    file:
    # Return a module that gets lib as an argument
    { lib, ... }:
    let
      dir = toString (builtins.dirOf file);
      data = builtins.fromTOML (builtins.readFile file);

      extraModulesPath = toString ../extra;
      extraModules = builtins.readDir extraModulesPath;

      importModule =
        str:
        let
          repoFile = "${dir}/${str}";
          extraFile = "${extraModulesPath}/${builtins.replaceStrings [ "." ] [ "/" ] str}.nix";
        in
        # First try to import from the user's repository
        if lib.hasPrefix "./" str || lib.hasSuffix ".nix" str || lib.hasSuffix ".toml" str then
          (if lib.hasSuffix ".toml" str then importTOML repoFile else import repoFile)
        # Then fallback on the extra modules
        else
          import extraFile;
    in
    {
      _file = file;
      imports = map importModule (data.imports or [ ]);
      config = builtins.removeAttrs data [ "imports" ];
    };
in
importTOML
