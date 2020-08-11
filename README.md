# devshell - a mkShell for developers.

**STATUS: unstable**

This project is for [Nix](https://nixos.org/nix) users. In short, it's a
`pkgs.mkShell` replacement. Eventually, it will find its way into `nixpkgs`
once it has become stable.

## Story time!

A long long time ago, `shell.nix` files would be written like this:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "myproject";
  buildInputs = [ pkgs.go ];
  shellHook = ''
    unset GOROOT GOPATH
    export GO111MODULE=on
  '';
}
```

This was repetitive so I introduced `pkgs.mkShell`, which was a marginal
improvement over this:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [ pkgs.go ];
  shellHook = ''
    unset GOROOT GOPATH
    export GO111MODULE=on
  '';
}
```

As you can see, not a lot has changed. The main difference it introduces is
the notion that shell environments are not supposed to be built, as they don't
act like regular packages.

Now this is the third round. Enter `mkDevShell` (assuming it's in `nixpkgs`):

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkDevShell {
  packages = [ pkgs.go ];
  env.GO111MODULE = "on";
}
```

There is also a TOML mode available where you write:

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkDevShell.fromTOML ./devshell.toml
```

and then in the TOML file:
```toml
[main]
packages = [ "go" ]

[env]
GO111MODULE = "on"
```

But there is more to it, see below:

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
direnv: export +DEVSHELL_DIR +DEVSHELL_ROOT +IN_NIX_SHELL +NIXPKGS_PATH ~PATH
```

There are new environment variables useful to support the day-to-day
activities:
* `DEVSHELL_DIR`: contains all the programs.
* `DEVSHELL_ROOT`: points to the project root.
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
### Welcome to mkDevShell ####

Commands:
  devshell-menu
  devshell-root
  nixpkgs-fmt

Aliases:
  hello
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

### --pure mode

Sometimes you want to run things in a slightly more pure mode. For example in
a CI environment, to make sure that all the dev dependencies are captured.

### Doctor / nix version check

Not everything can be nicely sandboxed. Is it possible to get a fast doctor
script that checks that everything is in good shape?

### Support other shells

What? Not everyone is using bash? Right now, support is already available in 
direnv mode.

