# Getting started

This project has a single dependency; Nix. It will be used to pull in all
other dependencies. It can be installed by following the instructions
over there: https://nixos.org/download.html#nix-quick-install

Now that's done, got to your project root and create an empty `devshell.toml`.

There are different ways to load that config depending on your preferences:

### Nix (non-flake)

Add another file called `shell.nix` with the following content. This file will
contain some nix code. Don't worry about the details.

```nix
{ system ? builtins.currentSystem }:
let
  src = fetchTarball "https://github.com/numtide/devshell/archive/main.tar.gz";
  devshell = import src { inherit system; };
in
devshell.fromTOML ./devshell.toml
```

> NOTE: it's probably a good idea to pin the dependency by replacing `main` with a git commit ID.

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

### Nix Flakes
For users of nix flakes, a default template is provided to get you up and
running.

```sh
nix flake new -t "github:numtide/devshell" project/

cd project/

# enter the shell
nix develop # or `direnv allow` if you want to use direnv
```

Find `templates/gettingStartedExample` in this repository for a working example of the additional configuration below: `env`, `packages`, and `serviceGroups`.

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
`devshell.packages` or as an entry in the `[[commands]]` list (see [TOML docs](https://toml.io/en/v1.0.0#array-of-tables)). Commands are also added to the
menu so they might be preferable for discoverability.

As an exercise, add the following snippet to your `devshell.toml`:

```toml
[[commands]]
package = "go"
```

Then re-enter the shell with `nix-shell`/`nix develop`/`direnv reload`. You should see something like this:

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

### Finding packages

Check out the [Nix package repository](https://search.nixos.org/packages).

Note that it is also possible to **use specific versions** for some packages - e.g. for NodeJS, [search the repo](https://search.nixos.org/packages?type=packages&query=nodejs) & use like this:
```toml
[[commands]]
package = "nodejs-17_x" # https://search.nixos.org/packages?type=packages&query=nodejs
name = "node"
help = "NodeJS"
```

Or another example:
```toml
[devshell]
packages = [
  "python27", # 2.7
  "python311", # 3.11
]
```


## Adding background services

Many projects need background services to be running during development or to
run tests (e.g. a database, caching server, webserver, ...). This is supported
in devshell through the concept of service groups.

A service group defines a collection of long-running processes that can be
started and stopped.

An example service group could be configured like this:
```toml
[serviceGroups.database]
description = "Runs a database in the backgroup"
[serviceGroups.database.services.postgres]
command = "postgres"
[serviceGroups.database.services.memcached]
command = "memcached"
```

This will add two commands to the devshell: `database:start` and
`database:stop`. `database:start` starts the defined services in the `database`
group in the foreground and shows their output. `database:stop` can be executed
in a different shell to stop the processes (or press Ctrl-C in the main shell).

## Wrapping up

**devshell** is extensible in many different ways. In the next chapters we will
discuss the various ways in which it can be adapted to your project's needs.
