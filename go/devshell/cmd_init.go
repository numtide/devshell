package main

import (
	"os"
	"path/filepath"

	"github.com/urfave/cli/v2"
)

const initHeader = `
# See https://github.com/numtide/devshell
`

var cmdInit = &cli.Command{
	Name:  "init",
	Usage: "creates a new " + configFile + " file",
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

		// Generate the config
		cfg := &config{
			Name: name,
		}
		cfgStr := initHeader + configPrint(cfg)

		// Write the config file
		w, err := os.Create(filepath.Join(p, configFile))
		if err != nil {
			return err
		}
		_, err = w.WriteString(cfgStr)
		if err != nil {
			return err
		}
		return w.Close()
	},
}
