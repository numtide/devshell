package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/numtide/devshell/devshell/config"

	"github.com/urfave/cli/v2"
)

// TODO: embed <devshell> with the executable.
const shellNix = `
let
	pkgs = import <devshell> {};
in
pkgs.mkDevShell.fromTOML %s
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
			Value: "",
		},
		&cli.StringSliceFlag{
			Name:  "I",
			Usage: "Add a path to the NIX_PATH",
			Value: cli.NewStringSlice("devshell=https://github.com/numtide/devshell/archive/main.tar.gz"),
		},
	},
	Action: func(c *cli.Context) error {
		var err error

		args := []string{"--show-trace"}
		path := c.String("path")
		paths := c.StringSlice("I")

		if path == "" {
			path, err = os.Getwd()
			if err != nil {
				return err
			}
		}
		path, err = filepath.Abs(path)
		if err != nil {
			return err
		}

		// Search for the config if it doesn't exist
		file, ret := config.Search(path)

		// Prepare arguments
		switch ret {
		case config.SearchNix:
			args = append(args, file)
		case config.SearchTOML:
			args = append(args, "--expr", fmt.Sprintf(shellNix, file))
		case config.SearchNone:
			return fmt.Errorf("no devshell found in %s", path)
		}

		for _, p := range paths {
			args = append(args, "-I", p)
		}

		// Instantiate eval
		drvPath, err := run("nix-instantiate", args...)
		if err != nil {
			return err
		}
		// Remove the surrounding quotes
		drvPath = strings.Trim(drvPath, "\"")
		// Realize
		outPath, err := run("nix-store", "--realize", drvPath)
		if err != nil {
			return err
		}
		// Execute
		cmd := exec.Command(outPath, c.Args().Slice()...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}
