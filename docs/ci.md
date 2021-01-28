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

All the CI has to do, is this: `$(nix-build shell.nix) make`.

1. `nix-build shell.nix` outputs a path to the entrypoint script
2. The entrypoint script is executed with `make` as an argument. It loads the
   environment.
3. Finally make is executed in the context of the project environment, with
   all the same dependencies as the developer's.

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

