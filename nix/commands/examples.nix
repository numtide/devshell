{ system ? builtins.currentSystem
, pkgs ? import ../nixpkgs.nix { inherit system; }
}:
let inherit (pkgs) lib; in
{
  nested = {
    "category 1" = [
      {
        prefix = "nix run .#";
        prefixes = {
          a.b = {
            d = "nix run ../#";
          };
        };
        packages = {
          a.b = {
            jq-1 = [ "[package] jq description" pkgs.jq ];
            yq-1 = pkgs.yq-go;
            yq-2 = pkgs.yq-go;
          };
          npm = "nodePackages.npm";
        };
        help = "[package] default description";
        helps = {
          a.b = {
            jq-1 = "[package] another jq description";
            yq-1 = "[package] yq description";
          };
        };
      }
      {
        packages.a.b = { inherit (pkgs) hyperfine findutils; };
        expose = true;
        exposes.a.b.hyperfine = false;
      }
      {
        commands.a.b.awk = ''${lib.getExe pkgs.gawk} $@'';
        helps.a.b.awk = "[command] run awk";

        commands.a.b.jq-2 = [ "[command] run jq" "${lib.getExe pkgs.jq} $@" ];

        commands."command with spaces" = ''printf "hello\n"'';
        helps."command with spaces" = ''[command] print "hello"'';
      }
      pkgs.python3
      [ "[package] vercel description" "nodePackages.vercel" ]
      "nodePackages.yarn"
      {
        package = pkgs.gnugrep;
      }
      {
        name = "run cowsay";
        help = "run hello";
        package = "cowsay";
      }
      {
        name = "run perl";
        help = "run perl";
        command = "${lib.getExe pkgs.perl} $@";
      }
      {
        name = "nix fmt";
        help = "format Nix files";
      }
    ];
    category-2 = [
      {
        package = pkgs.go;
      }
      [ "[package] run hello " "hello" ]
      pkgs.nixpkgs-fmt
    ];
  };

  flat = [
    {
      category = "scripts";
      package = "black";
    }
    [ "[package] print hello" "hello" ]
    "nodePackages.yarn"

    # uncomment to trigger errors:
    # [ "a" ]
    # [ "a" "b" "c" ]
  ];
}
