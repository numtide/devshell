# Getting started

This project depends on Nix. Install by following instructions over here:
https://nixos.org/download.html#nix-quick-install

Restart your shell and install the devshell CLI by running:

```console
$ nix-env -f https://github.com/numtide/devshell/archive/master.tar.gz -iA devshell
installing 'devshell'
building '/nix/store/f4xn9418503jn9r197w91y2m62mmnhzh-user-environment.drv'...
```

Finally, in the project root, run this command to create a `devshell.toml`
file:

```console
$ devshell init
```

Now you can enter the developer shell for the project:

```console
$ devshell enter
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
these 4 derivations will be built:
  /nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-your-project-bashrc.drv
  /nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-your-project-env.drv
  /nix/store/8027cgy3xcinb59aaynh899q953dnzms-your-project-bin.drv
  /nix/store/w33zl180ni880p18sls5ykih88zkmkqk-your-project.drv
building '/nix/store/nvbfq9h68r63k5jkfnbimny3b35sx0fs-your-project-bashrc.drv'...
building '/nix/store/ppfyf9zv023an8477hcbjlj0rbyvmwq7-your-project-env.drv'...
created 1 symlinks in user environment
building '/nix/store/8027cgy3xcinb59aaynh899q953dnzms-your-project-bin.drv'...
building '/nix/store/w33zl180ni880p18sls5ykih88zkmkqk-your-project.drv'...
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
🔨 Welcome to your-project

[general commands]

  menu - prints this menu

[your-project]$
```

Next, look at the `devshell.toml` configuration.
