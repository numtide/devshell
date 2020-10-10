package main

import (
	"log"

	"github.com/numtide/devshell/devshell/cmd"
)

func main() {
	err := cmd.Execute()
	if err != nil {
		log.Fatal(err)
	}
}
