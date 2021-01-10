package config

import (
	"os"
	"path/filepath"
)

// SearchResult is an "enum" returned by the Search function
type SearchResult int

const (
	// SearchNone is returned if no result is found
	SearchNone = SearchResult(0)
	// SearchNix is returned if a shell.nix is found
	SearchNix = SearchResult(1)
	// SearchTOML is returned if a devshell.toml is found
	SearchTOML = SearchResult(2)
)

// Search for a config file from `path` to up.
func Search(path string) (string, SearchResult) {
	for _, dir := range splitPath(path) {
		file := filepath.Join(dir, "shell.nix")
		if fileReadable(file) {
			return file, SearchNix
		}
		file = filepath.Join(dir, "devshell.toml")
		if fileReadable(file) {
			return file, SearchTOML
		}
	}
	return "", SearchNone
}

// fileReadable checks that the file will be accessible. The most reliable way
// to do this is to actually open the file.
func fileReadable(path string) bool {
	f, err := os.Open(path)
	if err != nil {
		return false
	}
	f.Close()
	return true
}

func splitPath(path string) []string {
	path = filepath.Clean(path)
	paths := []string{path}
	for i := len(path) - 1; i > 0; i-- {
		if path[i] == filepath.Separator {
			paths = append(paths, path[:i])
		}
	}
	return paths
}
