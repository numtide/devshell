# Options

## Available only in `Nix`

See how `commands.<name>` ([link](https://github.com/numtide/devshell/tree/main/nix/commands/examples.nix)) maps to `commands.*` ([link](https://github.com/numtide/devshell/tree/main/tests/extra/commands.lib.nix)).

### `commands.<name>.*`

A config for command(s) when the `commands` option is an attrset.

**Type**:

```console
(package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (nestedOptions) or (flatOptions)
```

**Example value**:

```nix
{
  category = [
    {
      packages.grep = pkgs.gnugrep;
    }
    pkgs.python3
    [ "[package] vercel description" "nodePackages.vercel" ]
    "nodePackages.yarn"
  ];
}
```

**Declared in**:

- [nix/commands/types.nix](https://github.com/numtide/devshell/tree/main/nix/commands/types.nix)

### `commands.<name>.*.packages (nestedOptions)`

A leaf value:

1. When a `string` with a value `<string>`,
   devshell tries to resolve a derivation
   `pkgs.<string>` and use it as `package (flatOptions)`.

2. When a `derivation`, it's used as `package (flatOptions)`.

3. When a list with two elements:
   1. The first element is a `string`
      that is used to select `help (flatOptions)`.
      
      Priority of this `string` (if present) when selecting `help (flatOptions)`: `4`.

      Lowest priority: `1`.
   2. The second element is interpreted as if
      the leaf value were initially a `string` or a `derivation`.

A path to a leaf value is concatenated via `.`
and used as `name (flatOptions)`.

Priority of `package.meta.description` (if present in the resolved `package (flatOptions)`) 
when selecting `help (flatOptions)`: `2`

Lowest priority: `1`.

A user may prefer to not bring to the environment some of the packages.

Priority of `expose = false` when selecting `expose (flatOptions)`: `1`.

Lowest priority: `1`.

**Type**:

```console
(nested (max depth is 100) attribute set of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ])))
```

**Default value**:

```nix
{ }
```

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.commands (nestedOptions)`

A leaf value:

1. When a `string`, it's used as `command (flatOptions)`.

2. When a list with two elements:
   1. The first element of type `string` with a value `<string>`
      is used to select `help (flatOptions)`.

      Priority of the `<string>` (if present) when selecting `help (flatOptions)`: `4`

      Lowest priority: `1`.
   1. The second element of type `string` is used as `command (flatOptions)`.

A path to the leaf value is concatenated via `.`
and used as `name (flatOptions)`.

**Type**:

```console
(nested (max depth is 100) attribute set of (string or (list with two elements of types: [ string string ])))
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.expose (nestedOptions)`

Can be used as `expose (flatOptions)` for all
`packages (nestedOptions)` and `commands (nestedOptions)`.

Priority of this option when selecting `expose (flatOptions)`: `2`.

When selecting `expose (flatOptions)` for
- `package (flatOptions)`, priority of `false`: `1`.
- `command (flatOptions)`, priority of `true`: `1`.

Lowest priority: `1`.

**Type**:

```console
null or boolean
```

**Default value**:

```nix
null
```

**Example value**:

```nix
{
  expose = true;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.exposes (nestedOptions)`

A leaf value can be used as `expose (flatOptions)`
for `package (flatOptions)` or `command (flatOptions)`
with a matching path in `packages (nestedOptions)` or `commands (nestedOptions)`.

Priority of this option when selecting `expose (flatOptions)`: `3`.

When selecting `expose (flatOptions)` for
- `package (flatOptions)`, priority of `false`: `1`.
- `command (flatOptions)`, priority of `true`: `1`.

Lowest priority: `1`.

**Type**:

```console
(nested (max depth is 100) attribute set of boolean)
```

**Default value**:

```nix
{ }
```

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  exposes.a.b = true;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.help (nestedOptions)`

Can be used as `hel (flatOptions)` for all
`packages (nestedOptions)` and `commands (nestedOptions)`.

Priority of this option when selecting a `help (flatOptions)`: `1`.

Lowest priority: `1`.

**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Example value**:

```nix
{
  help = "default help";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.helps (nestedOptions)`

A leaf value can be used as `help (flatOptions)`
for `package (flatOptions)` or `command (flatOptions)`
with a matching path in `packages (nestedOptions)` or `commands (nestedOptions)`.

Priority of this option when selecting `help (flatOptions)`: `3`.

Lowest priority: `1`.

**Type**:

```console
(nested (max depth is 100) attribute set of string)
```

**Default value**:

```nix
{ }
```

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  helps.a.b = "run jq";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.prefix (nestedOptions)`

Can be used as `prefix (flatOptions)` for all
`packages (nestedOptions)` and `commands (nestedOptions)`.

Priority of this option when selecting a `prefix (flatOptions)`: `1`.

Lowest priority: `1`.

**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Example value**:

```nix
{
  prefix = "nix run .#";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.prefixes (nestedOptions)`

A leaf value becomes `prefix (flatOptions)`
of `package (flatOptions)` or `command (flatOptions)`
with a matching path in `packages (nestedOptions)` or `commands (nestedOptions)`.

Priority of this option when selecting a `prefix (flatOptions)`: `2`.

Lowest priority: `1`.

**Type**:

```console
(nested (max depth is 100) attribute set of string)
```

**Default value**:

```nix
{ }
```

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  prefixes.a.b = "nix run ../#";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.package (flatOptions)`

Used to bring in a specific package. This package will be added to the
environment.

**Type**:

```console
null or (package or string convertible to it) or package
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.category (flatOptions)`

Sets a free text category under which this command is grouped
and shown in the devshell menu.

**Type**:

```console
string
```

**Default value**:

```nix
"[general commands]"
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.command (flatOptions)`

If defined, it will add a script with the name of the command, and the
content of this value.

By default it generates a bash script, unless a different shebang is
provided.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
''
  #!/usr/bin/env python
  print("Hello")
''
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.expose (flatOptions)`

When `true`, `command (flatOptions)`
or `package (flatOptions)` will be added to the environment.
  
Otherwise, they will not be added to the environment, but will be printed
in the devshell menu.

**Type**:

```console
boolean
```

**Default value**:

```nix
true
```

**Example value**:

```nix
true
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.help (flatOptions)`

Describes what the command does in one line of text.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.name (flatOptions)`

Name of the command.

Defaults to a `package (flatOptions)` name or pname if present.

The value of this option is required for `command (flatOptions)`.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.prefix (flatOptions)`

Prefix of the command name in the devshell menu.

**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)
## Available in `Nix` and `TOML`

### `commands`

Add commands to the environment.

**Type**:

```console
(list of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (flatOptions))) or (attribute set of list of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (nestedOptions) or (flatOptions)))
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
{
  packages = [
    "diffutils"
    "goreleaser"
  ];
  scripts = [
    {
      prefix = "nix run .#";
      inherit packages;
    }
    {
      name = "nix fmt";
      help = "format Nix files";
    }
  ];
  utilites = [
    [ "GitHub utility" "gitAndTools.hub" ]
    [ "golang linter" "golangci-lint" ]
  ];
}
```

**Declared in**:

- [modules/commands.nix](https://github.com/numtide/devshell/tree/main/modules/commands.nix)

### `commands.*`

A config for a command when the `commands` option is a list.

**Type**:

```console
(package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (flatOptions)
```

**Example value**:

```nix
[
  {
    category = "scripts";
    package = "black";
  }
  [ "[package] print hello" "hello" ]
  "nodePackages.yarn"
]
```

**Declared in**:

- [nix/commands/types.nix](https://github.com/numtide/devshell/tree/main/nix/commands/types.nix)

### `commands.*.package (flatOptions)`

Used to bring in a specific package. This package will be added to the
environment.

**Type**:

```console
null or (package or string convertible to it) or package
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.category (flatOptions)`

Sets a free text category under which this command is grouped
and shown in the devshell menu.

**Type**:

```console
string
```

**Default value**:

```nix
"[general commands]"
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.command (flatOptions)`

If defined, it will add a script with the name of the command, and the
content of this value.

By default it generates a bash script, unless a different shebang is
provided.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
''
  #!/usr/bin/env python
  print("Hello")
''
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.expose (flatOptions)`

When `true`, `command (flatOptions)`
or `package (flatOptions)` will be added to the environment.
  
Otherwise, they will not be added to the environment, but will be printed
in the devshell menu.

**Type**:

```console
boolean
```

**Default value**:

```nix
true
```

**Example value**:

```nix
true
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.help (flatOptions)`

Describes what the command does in one line of text.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.name (flatOptions)`

Name of the command.

Defaults to a `package (flatOptions)` name or pname if present.

The value of this option is required for `command (flatOptions)`.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.prefix (flatOptions)`

Prefix of the command name in the devshell menu.

**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `devshell.packages`

The set of packages to appear in the project environment.

Those packages come from <https://nixos.org/NixOS/nixpkgs> and can be
searched by going to <https://search.nixos.org/packages>

**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.packagesFrom`

Add all the build dependencies from the listed packages to the
environment.

**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.interactive.<name>.deps`

A list of other steps that this one depends on.

**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.interactive.<name>.text`

Script to run.

**Type**:

```console
string
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.load_profiles`

Whether to enable load etc/profiles.d/*.sh in the shell.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.meta`

Metadata, such as 'meta.description'. Can be useful as metadata for downstream tooling.

**Type**:

```console
attribute set of anything
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.motd`

Message Of The Day.

This is the welcome message that is being printed when the user opens
the shell.

You may use any valid ansi color from the 8-bit ansi color table. For example, to use a green color you would use something like {106}. You may also use {bold}, {italic}, {underline}. Use {reset} to turn off all attributes.

**Type**:

```console
string
```

**Default value**:

```nix
''
  {202}🔨 Welcome to devshell{reset}
  $(type -p menu &>/dev/null && menu)
''
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.name`

Name of the shell environment. It usually maps to the project name.

**Type**:

```console
string
```

**Default value**:

```nix
"devshell"
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.prj_root_fallback`

If IN_NIX_SHELL is nonempty, or DIRENV_IN_ENVRC is set to '1', then
PRJ_ROOT is set to the value of PWD.

This option specifies the path to use as the value of PRJ_ROOT in case
IN_NIX_SHELL is empty or unset and DIRENV_IN_ENVRC is any value other
than '1'.

Set this to null to force PRJ_ROOT to be defined at runtime (except if
IN_NIX_SHELL or DIRENV_IN_ENVRC are defined as described above).

Otherwise, you can set this to a string representing the desired
default path, or to a submodule of the same type valid in the 'env'
options list (except that the 'name' field is ignored).

**Type**:

```console
null or ((submodule) or non-empty string convertible to it)
```

**Default value**:

```nix
{
  eval = "$PWD";
}
```

**Example value**:

```nix
{
  # Use the top-level directory of the working tree
  eval = "$(git rev-parse --show-toplevel)";
};
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.prj_root_fallback.eval`

Like value but not evaluated by Bash. This allows to inject other
variable names or even commands using the `$()` notation.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"$OTHER_VAR"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.name`

Name of the environment variable
**Type**:

```console
string
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.prefix`

Prepend to PATH-like environment variables.

For example name = "PATH"; prefix = "bin"; will expand the path of
./bin and prepend it to the PATH, separated by ':'.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"bin"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.unset`

Whether to enable unsets the variable.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.value`

Shell-escaped value to set
**Type**:

```console
null or string or signed integer or boolean or package
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.startup.<name>.deps`

A list of other steps that this one depends on.

**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.startup.<name>.text`

Script to run.

**Type**:

```console
string
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `env`

Add environment variables to the shell.

**Type**:

```console
list of (submodule)
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[
  {
    name = "HTTP_PORT";
    value = 8080;
  }
  {
    name = "PATH";
    prefix = "bin";
  }
  {
    name = "XDG_CACHE_DIR";
    eval = "$PRJ_ROOT/.cache";
  }
  {
    name = "CARGO_HOME";
    unset = true;
  }
]
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.eval`

Like value but not evaluated by Bash. This allows to inject other
variable names or even commands using the `$()` notation.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"$OTHER_VAR"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.name`

Name of the environment variable
**Type**:

```console
string
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.prefix`

Prepend to PATH-like environment variables.

For example name = "PATH"; prefix = "bin"; will expand the path of
./bin and prepend it to the PATH, separated by ':'.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"bin"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.unset`

Whether to enable unsets the variable.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.value`

Shell-escaped value to set
**Type**:

```console
null or string or signed integer or boolean or package
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `extra.locale.package`

Set the glibc locale package that will be used on Linux
**Type**:

```console
package
```

**Default value**:

```nix
"pkgs.glibcLocales"
```

**Declared in**:

- [extra/locale.nix](https://github.com/numtide/devshell/tree/main/extra/locale.nix)

### `extra.locale.lang`

Set the language of the project
**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"en_GB.UTF-8"
```

**Declared in**:

- [extra/locale.nix](https://github.com/numtide/devshell/tree/main/extra/locale.nix)

### `git.hooks.enable`

Whether to enable install .git/hooks on shell entry.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.applypatch-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.commit-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.fsmonitor-watchman.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.post-update.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-applypatch.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-commit.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-merge-commit.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-push.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-rebase.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.prepare-commit-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `language.c.compiler`

Which C compiler to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.clang"
```

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.c.includes`

C dependencies from nixpkgs
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.c.libraries`

Use this when another language dependens on a dynamic library
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.go.package`

Which go package to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
<derivation go-1.21.5>
```

**Example value**:

```nix
pkgs.go
```

**Declared in**:

- [extra/language/go.nix](https://github.com/numtide/devshell/tree/main/extra/language/go.nix)

### `language.go.GO111MODULE`

Enable Go modules
**Type**:

```console
one of "on", "off", "auto"
```

**Default value**:

```nix
"on"
```

**Declared in**:

- [extra/language/go.nix](https://github.com/numtide/devshell/tree/main/extra/language/go.nix)

### `language.perl.package`

Which Perl package to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
<derivation perl-5.38.2>
```

**Example value**:

```nix
pkgs.perl538
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.perl.extraPackages`

List of extra packages (coming from perl5XXPackages) to add
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ perl538Packages.FileNext ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.perl.libraryPaths`

List of paths to add to PERL5LIB
**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ ./lib ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.ruby.package`

Ruby version used by your project
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.ruby_3_2"
```

**Declared in**:

- [extra/language/ruby.nix](https://github.com/numtide/devshell/tree/main/extra/language/ruby.nix)

### `language.ruby.nativeDeps`

Use this when your gems depend on a dynamic library
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/ruby.nix](https://github.com/numtide/devshell/tree/main/extra/language/ruby.nix)

### `language.rust.enableDefaultToolchain`

Enable the default rust toolchain coming from nixpkgs
**Type**:

```console
boolean
```

**Default value**:

```nix
"true"
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `language.rust.packageSet`

Which rust package set to use
**Type**:

```console
attribute set
```

**Default value**:

```nix
"pkgs.rustPlatform"
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `language.rust.tools`

Which rust tools to pull from the platform package set
**Type**:

```console
list of string
```

**Default value**:

```nix
[
  "rustc"
  "cargo"
  "clippy"
  "rustfmt"
]
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `serviceGroups`

Add services to the environment. Services can be used to group long-running processes.

**Type**:

```console
attribute set of (submodule)
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.description`

Short description of the service group, shown in generated commands

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.name`

Name of the service group. Defaults to attribute name in groups.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services`

Attrset of services that should be run in this group.

**Type**:

```console
attribute set of (submodule)
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services.<name>.command`

Command to execute.

**Type**:

```console
string
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services.<name>.name`

Name of this service. Defaults to attribute name in group services.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `services.postgres.package`

Which version of postgres to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.postgresql"
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.createUserDB`

Create a database named like current user on startup.
This option only makes sense when `setupPostgresOnStartup` is true.

**Type**:

```console
boolean
```

**Default value**:

```nix
true
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.initdbArgs`

Additional arguments passed to `initdb` during data dir
initialisation.

**Type**:

```console
list of string
```

**Default value**:

```nix
[
  "--no-locale"
]
```

**Example value**:

```nix
[
  "--data-checksums"
  "--allow-group-access"
]
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.setupPostgresOnStartup`

Whether to enable call setup-postgres on startup.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)
## Extra options available only in `Nix`

### `_module.args`

Additional arguments passed to each module in addition to ones
like `lib`, `config`,
and `pkgs`, `modulesPath`.

This option is also available to all submodules. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules. The sole exception to
this is the argument `name` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:
- {var}`lib`: The nixpkgs library.
- {var}`config`: The results of all options after merging the values from all modules together.
- {var}`options`: The options declared in all modules.
- {var}`specialArgs`: The `specialArgs` argument passed to `evalModules`.
- All attributes of {var}`specialArgs`

  Whereas option values can generally depend on other option values
  thanks to laziness, this does not apply to `imports`, which
  must be computed statically before anything else.

  For this reason, callers of the module system can provide `specialArgs`
  which are available during import resolution.

  For NixOS, `specialArgs` includes
  {var}`modulesPath`, which allows you to import
  extra modules from the nixpkgs package tree without having to
  somehow make the module aware of the location of the
  `nixpkgs` or NixOS directories.
  ```
  { modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
    ];
  }
  ```

For NixOS, the default value for this option includes at least this argument:
- {var}`pkgs`: The nixpkgs package set according to
  the {option}`nixpkgs.pkgs` option.

**Type**:

```console
lazy attribute set of raw value
```

**Declared in**:

- [lib/modules.nix]()