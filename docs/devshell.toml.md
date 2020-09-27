# `devshell.toml` documentation

All the arguments below are optional.

## Example

[$ ./devshell.toml](./devshell.toml) as toml
```toml
# This is the name of your environment. It should usually map to the project
# name.
name = "mkDevShell"

# Add packages from nixpkgs here. Use `nix search nixpkgs <term>` to find the
# package that you need.
#
# NOTE: don't forget to put commas between items! :)
packages = [
  "go",
  "mdsh",
]

# Message Of The Day (MOTD) is displayed when entering the environment with an
# interactive shell. By default it will show the project name.
#
# motd = ""

# Use this section to set environment variables to have in the environment.
#
# NOTE: all the values are escaped
[env]
FOO = 1

# These are bash-specific configurations. The idea is to maybe support other
# shell environments in the future, although it is not the case right now.
[bash]

# Loaded after the environment setup. Useful to set dynamic environment
# variables.
extra = """
export BAR=$FOO
"""

# Only loaded in interactive shells. NOTE: `nix-shell -c "ls"` is interactive
interactive = """

"""

# Declare commands that are available in the environment.
[[commands]]
help = "prints hello"
name = "hello"
command = "echo hello"

[[commands]]
help = "used to format Nix code"
name = "nixpkgs-fmt"
package = "nixpkgs-fmt"

[[commands]]
help = "github utility"
name = "hub"
package = "gitAndTools.hub"
```

## Schema

WIP

### The `name` field

The name of the package/project is determined by the name field, for example:

```toml
name = "Example"
```

The name can contain word characters `[a-zA-Z0-9_]`. For packages it is
recommended to follow the package naming guidelines.

The name field is optional and defaults to `devshell`.

### The `packages` field

### The `motd` field

### The `env` section

### The `bash.extra` field

### The `bash.internal` field

### The `commands` entries

* `command`:
* `help`:
* `name`:
* `package`:

