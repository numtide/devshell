package main

import (
	"os"

	"github.com/pelletier/go-toml"
)

const configFile = "devshell.toml"

type configBash struct {
	Extra       string `toml:"extra,omitempty"`
	Interactive string `toml:"interactive,omitempty"`
}

type configCommand struct {
	Alias   string `toml:"alias,omitempty"`
	Command string `toml:"command,omitempty"`
	Help    string `toml:"help,omitempty"`
	Name    string `toml:"name"`
	Package string `toml:"package,omitempty"`
}

type config struct {
	Name      string                 `toml:"name"`
	Packages  []string               `toml:"packages"`
	Motd      *string                `toml:"motd"`
	DevCaPath *string                `toml:"dev-ca-path,omitempty"`
	Env       map[string]interface{} `toml:"env"`
	Bash      configBash             `toml:"bash,omitempty"`
	Commands  []configCommand        `toml:"commands"`
	StaticDNS map[string]interface{} `toml:"static-dns,omitempty"`
}

func configLoad(path string) (*config, error) {
	r, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	c := &config{}
	err = toml.NewDecoder(r).Decode(c)
	if err != nil {
		return nil, err
	}

	return c, err
}

func configPrint(c *config) string {
	b, err := toml.Marshal(c)
	if err != nil {
		panic(err) // should never happen
	}
	return string(b)
}
