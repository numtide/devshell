package main

import (
	"log"

	"github.com/numtide/devshell/cmd"
)

func main() {
	err := cmd.Execute()
	if err != nil {
		log.Fatal(err)
	}
}
