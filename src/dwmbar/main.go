package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type statusBar struct {
	title       string
	now         statusField
	fans        statusField
	temperature statusField
	volume      statusField
	battery     statusField
	brightness  statusField
}

type kind int

type statusField struct {
	kind  kind
	value fmt.Stringer
	err   error
}

type getter[T fmt.Stringer] func() (T, error)

const (
	kindNow kind = iota + 1
	kindVolume
	kindFans
	kindBattery
	kindBrightness
	kindTemperature
)

func main() {
	updates := make(chan statusField, 8)

	go watch(updates, kindVolume, getterVolume)
	go watch(updates, kindNow, getterClock(argsClock{
		layout: "Monday, Jan 02 > 15:04", // https://go.dev/src/time/format.go
	}))
	go watch(updates, kindFans, getterFans(argsFans{
		cache: true,
	}))
	go watch(updates, kindBattery, getterBattery(argsBattery{
		cache: true,
	}))
	go watch(updates, kindBrightness, getterBrightness(argsBrightness{
		cache: true,
	}))
	go watch(updates, kindTemperature, getterTemperatures(argsTemperatures{
		cache:    true,
		separate: false,
	}))

	state := statusBar{title: getIdentity()}
	lastOutput := ""
	for update := range updates {
		switch update.kind {
		case kindNow:
			state.now = update
		case kindVolume:
			state.volume = update
		case kindFans:
			state.fans = update
		case kindBattery:
			state.battery = update
		case kindBrightness:
			state.brightness = update
		case kindTemperature:
			state.temperature = update
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
	case kindVolume:
		return "volume"
	case kindFans:
		return "fans"
	case kindBattery:
		return "battery"
	case kindBrightness:
		return "brightness"
	case kindNow:
		return "time"
	case kindTemperature:
		return "temperature"
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", u))
}

func updateInterval(u kind) time.Duration {
	switch u {
	case kindVolume:
		return 1 * time.Second
	case kindFans:
		return 1 * time.Second
	case kindBattery:
		return 1 * time.Second
	case kindBrightness:
		return 1 * time.Second
	case kindNow:
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
	return fmt.Sprintf("%s | %s | %s | %s | %s | %s | %s", s.title, s.fans, s.temperature, s.battery, s.brightness, s.volume, s.now)
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
			ch <- statusField{kind: kindNow, value: now}
			lastStr = s
		}
		time.Sleep(1 * time.Second)
	}
}

func getIdentity() string {
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
