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
  src = fetchTarball "https://github.com/numtide/devshell/archive/master.tar.gz"
  devshell = import src { inherit system; };
in
devshell.fromTOML ./devshell.toml
```

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

TODO:
* add some commands
* add some packages

Next, look at the `devshell.toml` configuration.
