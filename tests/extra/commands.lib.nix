{ pkgs, devshell, runTest }:
let inherit (pkgs) lib; in
{
  normalizeCommandsNested =
    let
      commands = (import ../../nix/commands/examples.nix { inherit pkgs; }).nested;
      check = (import ../../nix/commands/lib.nix { inherit pkgs; }).normalizeCommandsNested commands == [
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] jq description";
          name = "a.b.jq-1";
          package = pkgs.jq;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] yq description";
          name = "a.b.yq-1";
          package = pkgs.yq-go;
          prefix = "nix run ../#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Portable command-line YAML processor";
          name = "a.b.yq-2";
          package = pkgs.yq-go;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "a package manager for JavaScript";
          name = "npm";
          package = pkgs.nodePackages.npm;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";
          name = "a.b.findutils";
          package = pkgs.findutils;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Command-line benchmarking tool";
          name = "a.b.hyperfine";
          package = pkgs.hyperfine;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.gawk} $@";
          expose = false;
          help = "[command] run awk";
          name = "a.b.awk";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.jq} $@";
          expose = false;
          help = "[command] run jq";
          name = "a.b.jq-2";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = ''printf "hello\n"'';
          expose = false;
          help = ''[command] print "hello"'';
          name = "command with spaces";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = pkgs.python3.name;
          package = pkgs.python3;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "[package] vercel description";
          name = pkgs.nodePackages.vercel.name;
          package = pkgs.nodePackages.vercel;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = pkgs.nodePackages.yarn.name;
          package = pkgs.nodePackages.yarn;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          name = null;
          package = pkgs.gnugrep;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "run hello";
          name = "run cowsay";
          package = pkgs.cowsay;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.perl} $@";
          expose = true;
          help = "run perl";
          name = "run perl";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "format Nix files";
          name = "nix fmt";
          package = null;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          name = null;
          package = pkgs.go;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = "[package] run hello ";
          name = pkgs.hello.name;
          package = pkgs.hello;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          name = pkgs.nixpkgs-fmt.name;
          package = pkgs.nixpkgs-fmt;
          prefix = "";
        }
      ];
    in
    runTest "simple" { } ''
      ${
        if check
        then ''printf "OK"''
        else ''printf "Not OK"; exit 1''
      }
    '';
}
