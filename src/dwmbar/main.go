package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	home, err := os.UserHomeDir()
	if err != nil {
		panic(err.Error())
	}
	conf, err := newDefaultConfig(home)
	if err != nil {
		panic(err.Error())
	}
	bar, err := newDefaultBar(conf)
	if err != nil {
		panic(err.Error())
	}
	bar.run(conf)
}

func newDefaultConfig(home string) (config, error) {
	configPath := filepath.Join(home, configLocation)
	j, err := os.ReadFile(configPath)
	if err != nil {
		// Use default if no config is found
		if errors.Is(err, os.ErrNotExist) {
			return configDefault(), nil
		}
		// Other read errors are not tolerated
		fmt.Fprintf(os.Stderr, "error reading config file '%s': %s\n", configPath, err.Error())
		return config{}, err
	}

	var conf config
	if len(j) != 0 {
		err = json.Unmarshal(j, &conf)
		if err != nil {
			conf = configDefault()
			fmt.Fprintf(os.Stderr, "error unmarshaling json file '%s': %s\n", configPath, err.Error())
			fmt.Fprintf(os.Stderr, "using default config: %+v\n", conf)
		}
	}
	return conf, nil
}

func newDefaultBar(c config) (bar, error) {
	title := c.Title
	if title == "" {
		title = usernameAtHost()
	}
	bar := bar{
		title:   title,
		updates: make(chan field, 8),
		values:  newStates(),
	}
	// Use all fields if none specified
	fieldNames := c.Fields
	if len(fieldNames) == 0 {
		all := kinds()
		fieldNames = make([]string, len(all))
		for i := range all {
			fieldNames[i] = all[i].String()
		}
	}
	// Convert field names to kinds and store for display order
	bar.display = make([]kind, len(fieldNames))
	for i, name := range fieldNames {
		bar.display[i] = kindFromString(name)
	}
	return bar, nil
}
