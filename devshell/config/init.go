package config

import (
	"os"
	"path/filepath"
)

const initHeader = `
# See https://github.com/numtide/devshell
`

// Init ...
func Init(path string, name string) error {
	// Generate the config
	cfg := &Config{
		Name: name,
	}
	cfgStr := initHeader + Print(cfg)

	// Write the config file
	w, err := os.Create(filepath.Join(path, FileName))
	if err != nil {
		return err
	}
	_, err = w.WriteString(cfgStr)
	if err != nil {
		return err
	}
	return w.Close()
}
