# Getting started

This project has a single dependency; Nix. It will be used to pull in all
other dependencies. It can be installed by following the instructions
over there: https://nixos.org/download.html#nix-quick-install

Now that's done, got to your project root and create an empty `devshell.toml`.

There are different ways to load that config depending on your preferences:

Add another file called `shell.nix` with the following content. This file will
contain some nix code. Don't worry about the details.

```nix
{ system ? builtins.currentSystem }:
let
  src = fetchTarball "https://github.com/numtide/devshell/archive/master.tar.gz";
  devshell = import src { inherit system; };
in
devshell.fromTOML ./devshell.toml
```

> NOTE: it's probably a good idea to pin the dependency by replacing `master` with a git commit ID.

Now you can enter the developer shell for the project:

```console
$ nix-shell
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
these 4 derivations will be built:
  /nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-devshell-bashrc.drv
  /nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-devshell.env.drv
  /nix/store/8027cgy3xcinb59aaynh899q953dnzms-devshell-bin.drv
  /nix/store/w33zl180ni880p18sls5ykih88zkmkqk-devshell.drv
building '/nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-devshell-bashrc.drv'...
building '/nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-devshell-env.drv'...
created 1 symlinks in user environment
building '/nix/store/8027cgy3xcinb59aaynh899q953dnzms-devshell-bin.drv'...
building '/nix/store/w33zl180ni880p18sls5ykih88zkmkqk-devshell.drv'...
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
🔨 Welcome to devshell

[general commands]

  menu - prints this menu

[devshell]$
```

## Adding environment variables

Environment variables that are specific to the project can be added with the
`[[env]]` declaration. Each environment variable is an entry in an array, and
will be set in the order that they are declared.

Eg:

```toml
[[env]]
name = "GO111MODULE"
value = "on"
```

There are different ways to set the environment variables. Look at the schema
to find all the ways. But in short:
* Use the `value` key to set a fixed env var.
* Use the `eval` key to evaluate the value. This is useful when one env var
  depends on the value of another.
* Use the `prefix` key to prepend a path to an environment variable that uses
  the path separator. Like `PATH`.

## Adding new commands

Devshell also supports adding new commands to the environment. Those are
displayed on devshell entry so that the user knows what commands are available
to them.

In order to bring in new dependencies, you can either add them to
`devshell.packages` or to the `commands` list. Commands are also added to the
menu so they might be preferable for discovery.

As an exercise, add the following snippet to your `devshell.toml`:

```toml
[[commands]]
package = "go"
```

Then re-enter the shell with `nix-shell`. You should see something like this:

```console
$ nix-shell
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
these 4 derivations will be built:
  /nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-devshell-bashrc.drv
  /nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-devshell.env.drv
  /nix/store/8027cgy3xcinb59aaynh899q953dnzms-devshell-bin.drv
  /nix/store/w33zl180ni880p18sls5ykih88zkmkqk-devshell.drv
building '/nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-devshell-bashrc.drv'...
building '/nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-devshell-env.drv'...
created 1 symlinks in user environment
building '/nix/store/8027cgy3xcinb59aaynh899q953dnzms-devshell-bin.drv'...
building '/nix/store/w33zl180ni880p18sls5ykih88zkmkqk-devshell.drv'...
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
🔨 Welcome to devshell

[general commands]

  menu - prints this menu
  go   - The Go Programming language

[devshell]$
```

Now the `go` program is available in the environment and can be used to
develop Go programs. This can easily be adapted to any language.

Similarly, you could also add go to the packages list, in which case it would
not appear in the menu:

```toml
[devshell]
packages = [
  "go"
]
```

devshell is extensible in many different ways. In the next chapters we will
discuss the various ways in which it can be adapted to your project's needs.
to find 
of the configuration options available.
