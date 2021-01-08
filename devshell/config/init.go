package config

import (
	"fmt"
	"os"
	"path/filepath"
)

const initHeader = `# See https://github.com/numtide/devshell
`

// Init ...
func Init(path string, name string, force bool) error {
	// Generate the config
	cfg := &Config{
		Name: name,
	}
	cfgStr := initHeader + Print(cfg)

	// File path
	file := filepath.Join(path, FileName)

	// Abort if the file already exists
	_, err := os.Stat(file)
	if err == nil && !force {
		return fmt.Errorf("%s already exists", file)
	}
	
	// Write the config file
	w, err := os.Create(file)
	if err != nil {
		return err
	}
	_, err = w.WriteString(cfgStr)
	if err != nil {
		return err
	}
	return w.Close()
}
