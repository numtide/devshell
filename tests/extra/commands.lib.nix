{ pkgs, devshell, runTest }:
let inherit (pkgs) lib; in
{
  normalizeCommandsNested =
    let
      commands = (import ../../nix/commands/examples.nix { inherit pkgs; }).nested;
      normalizedCommands = (import ../../nix/commands/lib.nix { inherit pkgs; }).normalizeCommandsNested commands;
      check = normalizedCommands == [
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] jq description";
          interpolate = null;
          name = "a.b.jq-1";
          package = pkgs.jq;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "[package] yq description";
          interpolate = null;
          name = "a.b.yq-1";
          package = pkgs.yq-go;
          prefix = "nix run ../#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Portable command-line YAML processor";
          interpolate = null;
          name = "a.b.yq-2";
          package = pkgs.yq-go;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "a package manager for JavaScript";
          interpolate = null;
          name = "npm";
          package = pkgs.nodePackages.npm;
          prefix = "nix run .#";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "GNU Find Utilities, the basic directory searching utilities of the GNU operating system";
          interpolate = null;
          name = "a.b.findutils";
          package = pkgs.findutils;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = false;
          help = "Command-line benchmarking tool";
          interpolate = null;
          name = "a.b.hyperfine";
          package = pkgs.hyperfine;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.gawk} $@";
          expose = true;
          help = "[command] run awk";
          interpolate = null;
          name = "a.b.awk";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.jq} $@";
          expose = true;
          help = "[command] run jq";
          interpolate = null;
          name = "a.b.jq-2";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = ''printf "hello\n"'';
          expose = true;
          help = ''[command] print "hello"'';
          interpolate = null;
          name = "command with spaces";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          interpolate = null;
          name = pkgs.python3.name;
          package = pkgs.python3;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "[package] vercel description";
          interpolate = null;
          name = pkgs.nodePackages.vercel.name;
          package = pkgs.nodePackages.vercel;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          interpolate = null;
          name = pkgs.nodePackages.yarn.name;
          package = pkgs.nodePackages.yarn;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = null;
          interpolate = null;
          name = null;
          package = pkgs.gnugrep;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "run hello";
          interpolate = null;
          name = "run cowsay";
          package = pkgs.cowsay;
          prefix = "";
        }
        {
          category = "category 1";
          command = "${lib.getExe pkgs.perl} $@";
          expose = true;
          help = "run perl";
          interpolate = null;
          name = "run perl";
          package = null;
          prefix = "";
        }
        {
          category = "category 1";
          command = null;
          expose = true;
          help = "format Nix files";
          interpolate = null;
          name = "nix fmt";
          package = null;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          interpolate = null;
          name = null;
          package = pkgs.go;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = "[package] run hello ";
          interpolate = null;
          name = pkgs.hello.name;
          package = pkgs.hello;
          prefix = "";
        }
        {
          category = "category-2";
          command = null;
          expose = true;
          help = null;
          interpolate = null;
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
