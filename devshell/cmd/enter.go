package cmd

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
	pkgs = import <devshell> {};
in
pkgs.mkDevShell.fromTOML ./devshell.toml
`

func run(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("%s: %w", name, err)
	}
	return strings.TrimSpace(string(out)), nil
}

// Enter command
var Enter = &cli.Command{
	Name:    "enter",
	Aliases: []string{"run", "e"},
	Usage:   "builds and enters the shell",
	Description: `
	Enter the shell. If extra arguments are passed, run as a command inside
	the development environment instead.
	`,
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

		args := []string{"--show-trace"}
		exists, err := fileExists(shellFile)
		if err != nil {
			return err
		}
		if exists {
			args = append(args, shellFile)
		} else {
			args = append(args, "--expr", shellNix)
		}
		for _, p := range paths {
			args = append(args, "-I", p)
		}

		// instantiate eval
		drvPath, err := run("nix-instantiate", args...)
		if err != nil {
			return err
		}
		// remove the surrounding quotes
		drvPath = strings.Trim(drvPath, "\"")
		// realize
		outPath, err := run("nix-store", "--realize", drvPath)
		if err != nil {
			return err
		}
		// execute
		cmd := exec.Command(outPath, c.Args().Slice()...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}
