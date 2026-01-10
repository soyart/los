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

// statusBar defines the status bar current states
type statusBar struct {
	title        string
	clock        statusField
	fans         statusField
	temperatures statusField
	volume       statusField
	battery      statusField
	brightness   statusField
}

// poller is any simple function that returns a stringer.
// The function is called at interval by [poll].
//
// The return value `r` is mapped to string via `r.String()`,
// and the string is used as display value in our status bar.
type poller[T fmt.Stringer] func() (T, error)

// poll uses poller p to poll T at some interval, then wraps T
// with statusField and sends the field through chanel c
func poll[T fmt.Stringer](
	c chan<- statusField,
	k kind,
	p poller[T],
	interval time.Duration,
) {
	var last string
	for {
		val, err := p()
		if err != nil {
			c <- statusField{
				kind: k,
				err:  err,
			}
			time.Sleep(interval)
			continue
		}

		s := val.String()
		if s != last {
			c <- statusField{
				kind:  k,
				value: val,
			}
			last = s
		}
		time.Sleep(interval)
	}
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
		fmt.Fprintf(os.Stderr, "error reading config file '%s': %s\n", configPath, err.Error())
	}

	var conf config
	switch {
	case len(j) > 0:
		err = json.Unmarshal(j, &conf)
		if err != nil {
			conf = configDefault()
			fmt.Fprintf(os.Stderr, "error unmarshaling json file '%s': %s\n", configPath, err.Error())
			fmt.Fprintf(os.Stderr, "using default config: %+v\n", conf)
		}
	default:
		conf = configDefault()
	}

	updates := make(chan statusField, 8) // TODO: why 8 in the first place?
	go poll(updates, kindClock, pollClock(conf.Clock), defaultInterval(kindClock))
	go poll(updates, kindVolume, pollVolume, defaultInterval(kindVolume))
	go poll(updates, kindFans, pollFans(conf.Fans), defaultInterval(kindFans))
	go poll(updates, kindBattery, pollBattery(conf.Battery), defaultInterval(kindBattery))
	go poll(updates, kindBrightness, pollBrightness(conf.Brightness), defaultInterval(kindBrightness))
	go poll(updates, kindTemperatures, pollTemperatures(conf.Temperatures), defaultInterval(kindTemperatures))

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
		case kindTemperatures:
			state.temperatures = update
		}

		output := state.String()
		if output != lastOutput {
			os.Stdout.Write([]byte(output))
			lastOutput = output
		}
	}
}

func newStatusBar(c config) statusBar {
	return statusBar{title: c.Title}
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
	case kindTemperatures:
		return "temperature"
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", u))
}

func defaultInterval(k kind) time.Duration {
	switch k {
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
	case kindTemperatures:
		return 1 * time.Second
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", k))
}

func (s statusBar) String() string {
	return fmt.Sprintf("%s | %s | %s | %s | %s | %s | %s", s.title, s.fans, s.temperatures, s.battery, s.brightness, s.volume, s.clock)
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

type statusField struct {
	kind  kind
	value fmt.Stringer
	err   error
}

type kind int

const (
	kindClock kind = iota + 1
	kindVolume
	kindFans
	kindBattery
	kindBrightness
	kindTemperatures
)

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
