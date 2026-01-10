package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type statusBar struct {
	title        string
	clock        statusField
	fans         statusField
	temperatures statusField
	volume       statusField
	battery      statusField
	brightness   statusField
}

type kind int

type statusField struct {
	kind  kind
	value fmt.Stringer
	err   error
}

type config struct {
	Title        string           `json:"title"`
	Clock        argsClock        `json:"clock"`
	Fans         argsFans         `json:"fans"`
	Temperatures argsTemperatures `json:"temperatures"`
	Battery      argsBattery      `json:"battery"`
	Brightness   argsBrightness   `json:"brightness"`
}

type getter[T fmt.Stringer] func() (T, error)

const (
	configLocation = ".config/dwmbar/config.json"

	kindClock kind = iota + 1
	kindVolume
	kindFans
	kindBattery
	kindBrightness
	kindTemperature
)

func configDefault() config {
	return config{
		Title: usernameAtHost(),
		Clock: argsClock{
			Layout: "Monday, Jan 02 > 15:04", // https://go.dev/src/time/format.go
		},
		Fans: argsFans{
			Cache: true,
			Limit: 2,
		},
		Temperatures: argsTemperatures{
			Cache:    true,
			Separate: false,
		},
		Battery: argsBattery{
			Cache: true,
		},
		Brightness: argsBrightness{
			Cache: true,
		},
	}
}

func newStatusBar(c config) statusBar {
	return statusBar{title: c.Title}
}

func main() {
	home, err := os.UserHomeDir()
	if err != nil {
		panic(err.Error())
	}
	configPath := filepath.Join(home, configLocation)
	j, err := os.ReadFile(configPath)
	if err != nil {
		if !errors.Is(err, os.ErrNotExist) {
			panic(err.Error())
		}
		fmt.Fprintf(os.Stderr, "error reading config file '%s': %s", configPath, err.Error())
	}

	var conf config
	switch {
	case len(j) > 0:
		err = json.Unmarshal(j, &conf)
		if err != nil {
			conf = configDefault()
			fmt.Fprintf(os.Stderr, "error unmarshaling json file '%s': %s\n", configPath, err.Error())
			fmt.Fprintf(os.Stderr, "using default config: %+v", conf)
		}
	default:
		conf = configDefault()
	}

	updates := make(chan statusField, 8)

	go watch(updates, kindVolume, getterVolume)
	go watch(updates, kindClock, getterClock(conf.Clock))
	go watch(updates, kindFans, getterFans(conf.Fans))
	go watch(updates, kindBattery, getterBattery(conf.Battery))
	go watch(updates, kindBrightness, getterBrightness(conf.Brightness))
	go watch(updates, kindTemperature, getterTemperatures(conf.Temperatures))

	state := newStatusBar(conf)

	lastOutput := ""
	for update := range updates {
		switch update.kind {
		case kindClock:
			state.clock = update
		case kindVolume:
			state.volume = update
		case kindFans:
			state.fans = update
		case kindBattery:
			state.battery = update
		case kindBrightness:
			state.brightness = update
		case kindTemperature:
			state.temperatures = update
		}

		output := state.String()
		if output != lastOutput {
			os.Stdout.Write([]byte(output))
			lastOutput = output
		}
	}
}

func (u kind) String() string {
	switch u {
	case kindClock:
		return "time"
	case kindVolume:
		return "volume"
	case kindFans:
		return "fans"
	case kindBattery:
		return "battery"
	case kindBrightness:
		return "brightness"
	case kindTemperature:
		return "temperature"
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", u))
}

func updateInterval(u kind) time.Duration {
	switch u {
	case kindClock:
		return 1 * time.Second
	case kindVolume:
		return 1 * time.Second
	case kindFans:
		return 1 * time.Second
	case kindBattery:
		return 1 * time.Second
	case kindBrightness:
		return 1 * time.Second
	case kindTemperature:
		return 1 * time.Second
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", u))
}
func (s statusField) String() string {
	empty := statusField{}
	if s.kind == 0 {
		if s != empty {
			panic("unexpected kind=0 from non-empty statusField")
		}
		return "initializing ..."
	}
	if s.err != nil {
		return fmt.Sprintf("%s: %s", s.kind.String(), s.err.Error())
	}
	if s.value != nil {
		return s.value.String()
	}
	return fmt.Sprintf("%s: null", s.kind.String())
}

func (s statusBar) String() string {
	return fmt.Sprintf("%s | %s | %s | %s | %s | %s | %s", s.title, s.fans, s.temperatures, s.battery, s.brightness, s.volume, s.clock)
}

func watch[T fmt.Stringer](
	ch chan<- statusField,
	k kind,
	g getter[T],
) {
	interval := updateInterval(k)
	var lastStr string
	for {
		val, err := g()
		if err != nil {
			ch <- statusField{
				kind: k,
				err:  err,
			}
			time.Sleep(interval)
			continue
		}

		s := val.String()
		if s != lastStr {
			ch <- statusField{
				kind:  k,
				value: val,
			}
			lastStr = s
		}
		time.Sleep(interval)
	}
}

func watchTime(ch chan<- statusField) {
	var lastStr string
	for {
		now := time.Now()
		s := now.Format("Monday, Jan 02 > 15:04")
		if s != lastStr {
			ch <- statusField{kind: kindClock, value: now}
			lastStr = s
		}
		time.Sleep(1 * time.Second)
	}
}

func usernameAtHost() string {
	if len(os.Args) > 1 && os.Args[1] != "" {
		return os.Args[1]
	}
	user := os.Getenv("USER")
	if user == "" {
		user = "unknown"
	}
	host, err := os.Hostname()
	if err != nil {
		host = "unknown"
	}
	return fmt.Sprintf("%s@%s", user, host)
}

func readFile(path string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func findFirstMatch(pattern string) string {
	matches, err := filepath.Glob(pattern)
	if err != nil || len(matches) == 0 {
		return ""
	}
	return matches[0]
}

func findAllMatches(pattern string) []string {
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil
	}
	return matches
}
