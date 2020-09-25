package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/urfave/cli/v2"
)

const devShellNix = `
let
	pkgs = import <nixpkgs> {};
	mkDevShell =
		if pkgs ? mkDevShell then
		pkgs.mkDevShell
		else
		pkgs.callPackage (fetchTarball
		"https://github.com/numtide/devshell/archive/master.tar.gz") {}
		;
in
mkDevShell.fromTOML ./devshell.toml
`

func run() error {
	app := &cli.App{
		Name:        "devshell",
		Description: "THE developer shell",
		Commands: []*cli.Command{
			{
				Name:    "enter",
				Aliases: []string{"e"},
				Usage:   "builds and enters the shell",
				Action: func(c *cli.Context) error {
					// instantiate eval
					out, err := exec.Command("nix-instantiate", "--expr", devShellNix).Output()
					if err != nil {
						return err
					}
					drvPath := strings.TrimSpace(string(out))
					drvPath = strings.Trim(drvPath, "\"")
					fmt.Println("drvPath", drvPath)
					// realize
					out, err = exec.Command("nix-store", "--realize", drvPath).Output()
					if err != nil {
						return err
					}
					outPath := strings.TrimSpace(string(out))
					fmt.Println("outPath", outPath)
					// execute
					cmd := exec.Command(outPath, c.Args().Slice()...)
					cmd.Stdin = os.Stdin
					cmd.Stdout = os.Stdout
					cmd.Stderr = os.Stderr
					return cmd.Run()
				},
			},
		},
	}

	return app.Run(os.Args)
}

func main() {
	err := run()
	if err != nil {
		log.Fatal(err)
	}
}
