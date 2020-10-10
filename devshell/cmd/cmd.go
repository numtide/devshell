package cmd

import (
	"os"

	"github.com/urfave/cli/v2"
)

// Execute the main command
func Execute() error {
	app := &cli.App{
		Name:        "devshell",
		Description: "THE developer shell",
		Commands: []*cli.Command{
			Enter,
			Init,
		},
	}

	return app.Run(os.Args)
}
