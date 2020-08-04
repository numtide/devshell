# devshell - a shell for developers.

When switching from project to project, a common issue is to get all the
development dependencies.

Builds on top of Nix.

## Features

### A `devshell-menu`

When entering new development environments, it would be nice if it was
possible to type a standard command and get a list of the available tools.

### MOTD

Similar to the dev menu, to keep developers informed of the development
environment changes. This requires to record what version of the MOTD the
developer has seen and only show the new entries.

### `devshell.toml`

## Integrations

* nix-shell
* nix flakes
* direnv

## Features

### Bash completion by default

Life is not complete otherwise. Huhu.

Packages that contain bash completions will automatically be loaded by the
devshell.

## TODO

A lot of things!

### Documentation

Explain how all of this works and all the use-cases.

### Testing

Write integration tests for all of the use-cases.

### Lazy dependencies

This requires some coordination with the repository structure. To keep the
dev closure small, it would be nice to be able to load some of the
dependencies on demand.

### No nixpkgs

Nixpkgs is a fairly large dependency. It would be nice if the developer wasn't
forced to load it.

### --pure mode

Sometimes you want to run things in a slightly more pure mode. For example in
a CI environment, to make sure that all the dev dependencies are captured.

### Nix bootstrap

Some developers might not have Nix installed. I know! Ludicrous :-p but it
happens. Is it possible to bootstrap Nix.

### Doctor / nix version check

Not everything can be nicely sandboxed. Is it possible to get a fast doctor
script that checks that everything is in good shape?

### Support other shells

What? Not everyone is using bash?

