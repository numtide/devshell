# devshell - a shell for developers.

**STATUS: unstable**

The goal of this project is to put nix-shell on steroids.

## Features

### Compatible

* nix-shell
* nix flakes
* direnv

### Clean environment

Replace:
```
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_BUILD_TOP +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_INDENT_MAKE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +RUSTC +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +TEMP +TEMPDIR +TMP +TMPDIR +buildInputs +buildPhase +builder +builtDependencies +cargo_bins_jq_filter +cargo_build_options +cargo_options +cargo_release +cargo_test_options +cargoconfig +checkPhase +configureFlags +configurePhase +cratePaths +crate_sources +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +docPhase +dontAddDisableDepTrack +dontUseCmakeConfigure +installPhase +name +nativeBuildInputs +out +outputs +patches +preInstallPhases +propagatedBuildInputs +propagatedNativeBuildInputs +remapPathPrefix +shell +src +stdenv +strictDeps +system +version ~PATH
```
With:
```
direnv: export +DEVSHELL_DIR +DEVSHELL_ROOT +IN_NIX_SHELL ~PATH
```

* `DEVSHELL_DIR` contains all the programs.
* `DEVSHELL_ROOT` points to the project root.

### Common utilities

* `devshell-menu` - list all the programs available
* `devshell-root` - `cd` back to the project root.

### MOTD

When running `nix-shell` or `nix develop`, print a welcome message for new
developers:

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

Don't ask the users to learn Nix straight out of the box. Nix is still
available for more advanced use-cases.

### Bash completion by default

Life is not complete otherwise. Huhu.

Packages that contain bash completions will automatically be loaded by the
devshell in `nix-shell` or `nix develop` modes.

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

