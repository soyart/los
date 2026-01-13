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
	run(overrideEmpty(conf))
}

func run(c config) {
	display := kindsFromStrings(c.Fields)
	updates := make(chan field, len(display)+1)
	for _, k := range display {
		switch k {
		case kindClock:
			go poll(
				updates,
				kindClock,
				pollClock(c.Clock.Settings), c.Clock.Interval.Duration())

		case kindVolume:
			go poll(
				updates,
				kindVolume,
				pollVolume(c.Volume.Settings), c.Volume.Interval.Duration())

		case kindFans:
			go poll(
				updates,
				kindFans,
				pollFans(c.Fans.Settings), c.Fans.Interval.Duration())

		case kindBattery:
			go poll(
				updates,
				kindBattery,
				pollBattery(c.Battery.Settings), c.Battery.Interval.Duration())

		case kindBrightness:
			go poll(
				updates,
				kindBrightness,
				pollBrightness(c.Brightness.Settings), c.Brightness.Interval.Duration())

		case kindTemperatures:
			go poll(
				updates,
				kindTemperatures,
				pollTemperatures(c.Temperatures.Settings), c.Temperatures.Interval.Duration())

		case kindWifi:
			go live(
				updates,
				kindWifi,
				watchWifi(c.Wifi.Settings))
			// Backup poller to fallback to
			go poll(
				updates,
				kindWifi,
				pollWifi(c.Wifi.Settings), c.Wifi.Interval.Duration())
		}
	}

	// Only print when new change arrives
	// We test string for equality
	b := bar{
		title:   c.Title,
		display: display,
		values:  newStates(),
	}
	lastOutput := ""
	for update := range updates {
		b.values.set(update)
		output := b.String()
		if output == lastOutput {
			continue
		}
		os.Stdout.Write([]byte(output))
		lastOutput = output
	}
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
		fmt.Fprintf(os.Stderr, "reading config file '%s': %s\n", configPath, err.Error())
		return config{}, err
	}

	var conf config
	if len(j) != 0 {
		err = json.Unmarshal(j, &conf)
		if err != nil {
			conf = configDefault()
			fmt.Fprintf(os.Stderr, "unmarshaling json file '%s': %s\n", configPath, err.Error())
			fmt.Fprintf(os.Stderr, "using default config: %+v\n", conf)
		}
	}
	return conf, nil
}

func overrideEmpty(conf config) config {
	if conf.Title == "" {
		conf.Title = usernameAtHost()
	}
	if len(conf.Fields) == 0 {
		all := kinds()
		conf.Fields = make([]string, len(all))
		for i := range all {
			conf.Fields[i] = all[i].String()
		}
	}
	return conf
}
