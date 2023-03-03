# devshell - like virtualenv, but for all the languages.

**STATUS: unstable**

[![Devshell Dev Environment](https://img.shields.io/badge/nix-devshell-blue?logo=NixOS&labelColor=ccc)](https://github.com/numtide/devshell) [![Support room on Matrix](https://img.shields.io/matrix/devshell:numtide.com.svg?label=%23devshell%3Anumtide.com&logo=matrix&server_fqdn=matrix.numtide.com)](https://matrix.to/#/#devshell:numtide.com)

The goal of this project is to simplify per-project developer environments.

Imagine, a new employee joins the company, or somebody transfers teams, or
somebody wants to contribute to one of your Open Source projects. It
should take them 10 minutes to clone the repo and get all of the development
dependencies.

## Documentation

See [docs](docs)

## Features

### Compatible

Keep it compatible with:

* nix-shell
* direnv
* nix flakes

### Clean environment

`pkgs.stdenv.mkDerivation` and `pkgs.mkShell` build on top of the
`pkgs.stdenv` which introduces all sort of dependencies. Each added package,
like the `pkgs.go` in the "Story time!" section has the potential of adding
new environment variables, which then need to be unset. The `stdenv` itself
contains either GCC or Clang which makes it hard to select a specific C
compiler.

This is why `mkDevShell` builds its environment from a `builtins.derivation`.

direnv loads will change from:
```
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_BUILD_TOP +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_INDENT_MAKE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +RUSTC +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +TEMP +TEMPDIR +TMP +TMPDIR +buildInputs +buildPhase +builder +builtDependencies +cargo_bins_jq_filter +cargo_build_options +cargo_options +cargo_release +cargo_test_options +cargoconfig +checkPhase +configureFlags +configurePhase +cratePaths +crate_sources +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +docPhase +dontAddDisableDepTrack +dontUseCmakeConfigure +installPhase +name +nativeBuildInputs +out +outputs +patches +preInstallPhases +propagatedBuildInputs +propagatedNativeBuildInputs +remapPathPrefix +shell +src +stdenv +strictDeps +system +version ~PATH
```
to:
```
direnv: export +DEVSHELL_DIR +PRJ_DATA_DIR +PRJ_ROOT +IN_NIX_SHELL +NIXPKGS_PATH ~PATH
```

There are new environment variables useful to support the day-to-day
activities:
* `DEVSHELL_DIR`: contains all the programs.
* `PRJ_ROOT`: points to the project root.
* `PRJ_DATA_DIR`: points to `$PRJ_ROOT/.data` by default. Is used to store runtime data.
* `NIXPKGS_PATH`: path to `nixpkgs` source.

### Common utilities

The shell comes pre-loaded with some utility functions. I'm not 100% sure if
those are useful yet:

* `devshell-menu` - list all the programs available
* `devshell-root` - `cd` back to the project root.

### MOTD

When entering a random project, it's useful to get a quick view of what
commands are available.

When running `nix-shell` or `nix develop`, `mkDevShell` prints a welcome
message:

```
### 🔨 Welcome to mkDevShell ####

# Commands

devshell-menu - print this menu
devshell-root - change directory to root
hello         - prints hello
nixpkgs-fmt   - used to format Nix code
```

### Configurable with a TOML file

You might be passionate about Nix, but people on the team might be afraid of
that non-mainstream technology. So let them write TOML instead. It should
handle 80% of the use-cases and falling back on Nix is always possible.

### Bash completion by default

Life is not complete otherwise. Huhu.

Packages that contain bash completions will automatically be loaded by
`mkDevShell` in `nix-shell` or `nix develop` modes.

### Capture development dependencies in CI

With a CI + Binary cache setup, one often wants to be able to capture all the
build inputs of a `shell.nix`. Before, `pkgs.mkShell` would even refuse to
build! (my fault really). With `pkgs.mkDevShell`, capturing all of the
development dependencies is as easy as:

```sh
nix-build shell.nix | cachix push <mycache>
```
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

### Doctor / nix version check

Not everything can be nicely sandboxed. Is it possible to get a fast doctor
script that checks that everything is in good shape?

### Support other shells

What? Not everyone is using bash? Right now, support is already available in 
direnv mode.

# Contributing

## Dev Setup

### Docs

1. Change files in `docs/`
2. Run `docs/serve.sh` (or the task in VSCode)
3. Visit [`localhost:8000`](http://localhost:8000)
