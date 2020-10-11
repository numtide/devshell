package main

import (
	"log"

	"github.com/numtide/devshell/cmd"
)

// These values are automatically set by `goreleaser` or can be set with
// `go build -ldflags="-X main.version=something"` for example.
var (
// version = "dev"
// commit  = "unknown"
// date    = "unknown"
// builtBy = "unknown"
)

func main() {
	err := cmd.Execute()
	if err != nil {
		log.Fatal(err)
	}
}
