package config

import (
	"os"

	"github.com/pelletier/go-toml"
)

// FileName ...
const FileName = "devshell.toml"

// Bash ...
type Bash struct {
	Extra       string `toml:"extra,omitempty"`
	Interactive string `toml:"interactive,omitempty"`
}

// Command ...
type Command struct {
	Alias   string `toml:"alias,omitempty"`
	Command string `toml:"command,omitempty"`
	Help    string `toml:"help,omitempty"`
	Name    string `toml:"name"`
	Package string `toml:"package,omitempty"`
}

// Config ...
type Config struct {
	Name     string                 `toml:"name"`
	Packages []string               `toml:"packages"`
	Motd     *string                `toml:"motd"`
	Env      map[string]interface{} `toml:"env"`
	Bash     Bash                   `toml:"bash,omitempty"`
	Commands []Command              `toml:"commands"`
}

// Load ...
func Load(path string) (*Config, error) {
	r, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	c := &Config{}
	err = toml.NewDecoder(r).Decode(c)
	if err != nil {
		return nil, err
	}

	return c, err
}

// Print ...
func Print(c *Config) string {
	b, err := toml.Marshal(c)
	if err != nil {
		panic(err) // should never happen
	}
	return string(b)
}
