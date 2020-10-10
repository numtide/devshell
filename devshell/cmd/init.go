package cmd

import (
	"os"
	"path/filepath"

	"github.com/numtide/devshell/devshell/config"

	"github.com/urfave/cli/v2"
)

// Init command
var Init = &cli.Command{
	Name:  "init",
	Usage: "creates a new " + config.FileName + " file",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "name",
			Usage: "name of the project",
		},
		&cli.StringFlag{
			Name:  "path",
			Usage: "project folder",
			Value: ".",
		},
	},
	Action: func(c *cli.Context) error {
		// Load the arguments
		p := c.String("path")
		name := c.String("name")
		if name == "" {
			p2, err := filepath.Abs(p)
			if err != nil {
				return err
			}
			name = filepath.Base(p2)
		}

		return config.Init(p, name)
	},
}
