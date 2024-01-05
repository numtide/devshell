# Using a devshell as a Nix application

Devshells provide the attribute `flakeApp`, which contains an attribute set
suitable for use as an entry in the `apps` flake output structure.  Export this
attribute under `apps.<system>.<myapp>`, and then you can run commands within
your devshell as follows:

```sh
nix run '.#<myapp>' -- <devshell-command> <and-args>
```

For example, given the following `flake.nix`:

```nix
{
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      apps.devshell = self.outputs.devShells.${system}.default.flakeApp;

      devShells.default =
        let
          pkgs = import nixpkgs {
            inherit system;

            overlays = [ devshell.overlays.default ];
          };
        in
        pkgs.devshell.mkShell ({ config, ... }: {
          commands = [
            {
              name = "greet";
              command = ''
                printf -- 'Hello, %s!\n' "''${1:-world}"
              '';
            }
          ];
        });
    });
}
```

You can execute your devshell's `greet` command like this:

```console
$ nix run '.#devshell' -- greet myself
Hello, myself!
```

## Setting `PRJ_ROOT`

By default, the `PRJ_ROOT` environment variable is set to the value of the
`PWD` environment variable.  You can override this by defining `PRJ_ROOT` in
`nix run`'s environment:

```sh
PRJ_ROOT=/some/where/else nix run '.#<myapp>' -- <devshell-command> <and-args>
```

You can also use the `--prj-root` option:

```sh
nix run '.#<myapp>' -- --prj-root /yet/another/path -- <devshell-command> <and-args>
```
