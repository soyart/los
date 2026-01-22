package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"
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
	display := c.displayOrder()
	updates := make(chan field, len(display)+1)
	for _, k := range display {
		switch k {
		case kindClock:
			go poll(
				k,
				updates,
				pollClock(c.Clock.Settings),
				c.Clock.Interval.Duration(),
			)

		case kindVolume:
			go poll(
				k,
				updates,
				pollVolume(c.Volume.Settings),
				c.Volume.Interval.Duration(),
			)

		case kindFans:
			go poll(
				k,
				updates,
				pollFans(c.Fans.Settings),
				c.Fans.Interval.Duration(),
			)

		case kindBattery:
			go poll(
				k,
				updates,
				pollBattery(c.Battery.Settings),
				c.Battery.Interval.Duration(),
			)

		case kindBrightness:
			go poll(
				k,
				updates,
				pollBrightness(c.Brightness.Settings),
				c.Brightness.Interval.Duration(),
			)

		case kindTemperatures:
			go poll(
				k,
				updates,
				pollTemperatures(c.Temperatures.Settings),
				c.Temperatures.Interval.Duration(),
			)

		case kindWifi:
			// Real-time wifi status
			go live(
				k,
				updates,
				watchWifi(c.Wifi.Settings))

			// Backup interval poller to fallback to
			go poll(
				k,
				updates,
				pollWifi(c.Wifi.Settings),
				c.Wifi.Interval.Duration(),
			)
		}
	}

	// Only print when new change arrives
	// We test string for equality
	b := bar{
		title:  c.Title,
		values: newStates(display),
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
	// Use default if file is empty
	if len(j) == 0 {
		return configDefault(), nil
	}

	var conf config
	err = json.Unmarshal(j, &conf)
	if err != nil {
		conf = configDefault()
		fmt.Fprintf(os.Stderr, "unmarshaling json file '%s': %s\n", configPath, err.Error())
		fmt.Fprintf(os.Stderr, "using default config: %+v\n", conf)
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

func configDefault() config {
	return config{
		Title: usernameAtHost(),
		Fields: func() []string {
			all := kinds()
			return kindStrings(all[:])
		}(),
		Clock: withInterval[argsClock]{
			Interval: duration(1 * time.Second),
			Settings: argsClock{
				// https://go.dev/src/time/format.go
				Layout: defaultClockLayout,
			},
		},
		Volume: withInterval[argsVolume]{
			Interval: duration(200 * time.Millisecond),
			Settings: argsVolume{
				Backend: backendPipewire,
			},
		},
		Fans: withInterval[argsFans]{
			Interval: duration(1 * time.Second),
			Settings: argsFans{
				Cache: true,
				Limit: 2,
			},
		},
		Temperatures: withInterval[argsTemperatures]{
			Interval: duration(5 * time.Second),
			Settings: argsTemperatures{
				Cache: true,
				Merge: true,
			},
		},
		Battery: withInterval[argsBattery]{
			Interval: duration(5 * time.Second),
			Settings: argsBattery{
				Cache: true,
			},
		},
		Brightness: withInterval[argsBrightness]{
			Interval: duration(500 * time.Millisecond),
			Settings: argsBrightness{
				Cache: true,
			},
		},
		Wifi: withInterval[argsWifi]{
			Interval: duration(30 * time.Second), // Heartbeat interval for signal fallback
			Settings: argsWifi{
				Backend: backendWifiAuto,
			},
		},
	}
}
