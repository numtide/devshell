package cmd

import (
	"fmt"
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
		&cli.BoolFlag{
			Name:  "force",
			Usage: "override the file if it already exists",
		},
	},
	Action: func(c *cli.Context) error {
		// Load the arguments
		p := c.String("path")
		name := c.String("name")
		force := c.Bool("force")

		// Default name based on the current folder name
		if name == "" {
			p2, err := filepath.Abs(p)
			if err != nil {
				return err
			}
			name = filepath.Base(p2)
		}

		err := config.Init(p, name, force)
		if err != nil {
			return err
		}
		fmt.Println("config file created")

		return nil
	},
}
