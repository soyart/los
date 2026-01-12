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
	conf, err := newConfig(home)
	if err != nil {
		panic(err.Error())
	}
	bar, err := newBar(conf)
	if err != nil {
		panic(err.Error())
	}
	bar.run()
}

func newConfig(home string) (config, error) {
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

func newBar(c config) (bar, error) {
	title := c.Title
	if title == "" {
		title = usernameAtHost()
	}

	bar := bar{title: title}
	bar.updates = make(chan field, 8) // TODO: why 8 in the first place?
	bar.values = newStates()

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
	bar.fields = make([]kind, len(fieldNames))
	for i, name := range fieldNames {
		bar.fields[i] = kindFromString(name)
	}

	for _, k := range bar.fields {
		switch k {
		case kindClock:
			go poll(
				bar.updates,
				kindClock,
				pollClock(c.Clock.Settings), c.Clock.Interval.Duration())

		case kindVolume:
			go poll(
				bar.updates,
				kindVolume,
				pollVolume(c.Volume.Settings), c.Volume.Interval.Duration())

		case kindFans:
			go poll(
				bar.updates,
				kindFans,
				pollFans(c.Fans.Settings), c.Fans.Interval.Duration())

		case kindBattery:
			go poll(
				bar.updates, kindBattery,
				pollBattery(c.Battery.Settings), c.Battery.Interval.Duration())

		case kindBrightness:
			go poll(
				bar.updates,
				kindBrightness,
				pollBrightness(c.Brightness.Settings), c.Brightness.Interval.Duration())

		case kindTemperatures:
			go poll(
				bar.updates,
				kindTemperatures,
				pollTemperatures(c.Temperatures.Settings), c.Temperatures.Interval.Duration())

		case kindWifi:
			go poll(
				bar.updates,
				kindWifi,
				pollWifi(c.Wifi.Settings), c.Wifi.Interval.Duration())
			go live(
				bar.updates,
				kindWifi,
				watchWifi(c.Wifi.Settings))
		}
	}
	return bar, nil
}
