{
  description = "devshell";

  outputs = { self }:
    let
      eachSystem = f:
        let
          op = attrs: system:
            let
              ret = f system;
              op2 = attrs: key:
                attrs // {
                  ${key} = (attrs.${key} or { }) // { ${system} = ret.${key}; };
                };
            in
            builtins.foldl' op2 attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } [
          "aarch64-linux"
          "i686-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

      forSystem = system:
        let
          pkgs = import ./. { inherit system; };
        in
        rec {
          defaultPackage = pkgs.devshell;

          legacyPackages = pkgs;

          devShell = pkgs.devshell-shell;
        };
    in
    {
      # Import this overlay into your instance of nixpkgs
      overlay = import ./overlay.nix;
    }
    //
    eachSystem forSystem;
}
