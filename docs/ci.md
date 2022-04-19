# Continuous Integration setup (CI)

Traditionally, the CI build environment has to be kept in sync with the
project. If the project needs `make` to build, the CI has to be configured to
have it available. This can become quite tricky whenever a version requirement
changes.

With devshell, the only dependency is Nix. Once the devshell is built, all the
dependencies are loaded into scope and automatically are in sync with the
current code checkout.

## General approach

The only dependency we need installed in the CI environment is Nix.

Assuming that the `shell.nix` file exists, the general approach is to build it
with nix to get back the entrypoint script. And then executed that script with
the commands.

For example, let's say that `make` is being used to build the project.

The `devshell.toml` would have it as part of its commands:
```toml
[[commands]]
package = "gnumake"
```

All the CI has to do, is this: `nix-shell --run "$(nix-build shell.nix)/entrypoint make"`.

1. `$(nix-build shell.nix)/entrypoint` outputs a path to the entrypoint script
1. `nix-shell --run` sets the required environment variables for the entrypoint script to work.
2. The entrypoint script is executed with `make` as an argument. It loads the
   environment.
3. Finally make is executed in the context of the project environment, with
   all the same dependencies as the developer's.

## Hercules CI

[Hercules CI](https://hercules-ci.com) is a Nix-based continuous integration and deployment service.

### Build

If you haven't packaged your project with Nix or if a check can't run in the Nix sandbox, you can run it as an [effect](https://docs.hercules-ci.com/hercules-ci/effects/).

`ci.nix`
```
let
  shell = import ./shell.nix {};
  pkgs = shell.pkgs;
  effectsSrc =
    builtins.fetchTarball "https://github.com/hercules-ci/hercules-ci-effects/archive/COMMIT_HASH.tar.gz";
  inherit (import effectsSrc { inherit pkgs; }) effects;
in
{
  inherit shell;
  build = effects.mkEffect {
    src = ./.;
    effectScript = ''
      go build
    '';
    inputs = [
      shell.hook
    ];
  };
}
```

Replace COMMIT_HASH by the latest git sha from [`hercules-ci-effects`](https://github.com/hercules-ci/hercules-ci-effects/commit/master),
or, if you prefer, you can bring `effects` into scope [using another pinning method](https://docs.hercules-ci.com/hercules-ci-effects/guide/import-or-pin/).

### Run locally

The [`hci` command](https://docs.hercules-ci.com/hercules-ci-agent/hci/) is available in `nixos-21.05` and `nixos-unstable`.

`devshell.toml`
```
[[commands]]
package = "hci"
```

Use [`hci effect run`](https://docs.hercules-ci.com/hercules-ci-agent/hci/). Following the previous example:

```console
hci effect run build --no-token
```

### Shell only

To build the shell itself on `x86_64-linux`:

`ci.nix`
```
{
  shell = import ./shell.nix {};

  # ... any extra Nix packages you want to build; perhaps
  # pkgs = import ./default.nix {} // { recurseForDerivations = true; };
}
```

### `system`

If you build for [multiple systems](https://docs.hercules-ci.com/hercules-ci/guides/multi-platform/), pass `system`:

```
import ./shell.nix { inherit system; };
```

## GitHub Actions

Add the following file to your project. Replace the `<your build command>`
part with whatever is needed to build the project.

`.github/workflows/devshell.yml`
```yaml
name: devshell
on:
  push:
    branches:
      - master
  pull_request:
  workflow_dispatch:
jobs:
  build:
    strategy:
      matrix:
        os: [ ubuntu-20.04, macos-latest ]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v2
      - uses: cachix/install-nix-action@v12
      - uses: cachix/cachix-action@v8
        with:
          name: "<your cache here>"
          signingKey: '${{ secrets.CACHIX_SIGNING_KEY }}'
      - run: |
          source "$(nix-build shell.nix)"
          <your build command>
```

## TODO

Add more CI-specific examples.

