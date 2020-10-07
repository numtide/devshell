package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/urfave/cli/v2"
)

const shellNix = `
let
	pkgs = import <nixpkgs> {};
	mkDevShell = pkgs.callPackage <devshell> {};
in
mkDevShell.fromTOML ./devshell.toml
`

var cmdEnter = &cli.Command{
	Name:    "enter",
	Aliases: []string{"e"},
	Usage:   "builds and enters the shell",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "path",
			Usage: "path to the project root",
			Value: ".",
		},
		&cli.StringSliceFlag{
			Name:  "I",
			Usage: "Add a path to the NIX_PATH",
			Value: cli.NewStringSlice("devshell=https://github.com/numtide/devshell/archive/master.tar.gz"),
		},
	},
	Action: func(c *cli.Context) error {
		path := c.String("path")
		paths := c.StringSlice("I")
		shellFile := filepath.Join(path, "shell.nix")

		args := []string{"-v"}
		exists, err := fileExists(shellFile)
		if err != nil {
			return err
		}
		if !exists {
			args = append(args, "--expr", shellNix)
		}
		for _, p := range paths {
			args = append(args, "-I", p)
		}

		// instantiate eval
		out, err := exec.Command("nix-instantiate", args...).Output()
		if err != nil {
			return fmt.Errorf("nix-instantiate: %w", err)
		}
		drvPath := strings.TrimSpace(string(out))
		drvPath = strings.Trim(drvPath, "\"")
		// realize
		out, err = exec.Command("nix-store", "--realize", drvPath).Output()
		if err != nil {
			return fmt.Errorf("nix-store: %w", err)
		}
		outPath := strings.TrimSpace(string(out))
		// execute
		cmd := exec.Command(outPath, c.Args().Slice()...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}
