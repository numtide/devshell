# Extending devshell

When the base modules that are provided by devshell are not enough, it is
possible to extend it.

## Extra modules

All the `devshell.toml` schema options that are prefixed with `extra.<name>`
are only loaded on demand. This is done to keep devshell fast for users that
don't need all the modules.

In order to load an extra module, use the `<name>` in the import section. For
example to make the `extra.locale` options available, import `locale`:

`devshell.toml`:
```toml
imports = ["locale"]
```

Make sure to add this at the first statement in the file.

Now that the module has been loaded, the `devshell.toml` understands the extra
options:

```toml
imports = ["extra.locale"]

[extra.locale]
lang = "en_US.UTF-8"
```

## Building your own modules

Building your own modules requires to understand the Nix language. If Nix
this is too complicated, please reach out to the issue tracker and describe
your use-case. We want to be able to support a wide variety of development
scenario.

In the same way as previously introduced, devshell will also load files that
are relative to the `devshell.toml`. For example:

```toml
imports = ["mymodule.nix"]
```

Will load the `mymodule.nix` file in the project repository and extend the
`devshell.toml` schema accordingly.
