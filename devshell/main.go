package main

import (
	"log"
	"os"

	"github.com/urfave/cli/v2"
)

func run() error {
	app := &cli.App{
		Name:        "devshell",
		Description: "THE developer shell",
		Commands: []*cli.Command{
			cmdEnter,
			cmdInit,
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
