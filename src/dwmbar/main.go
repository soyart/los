package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	updates := make(chan statusField, 8)

	go watch(updates, kindVolume, getVolumeV2)
	go watch(updates, kindFans, getFansV2)
	go watch(updates, kindBattery, getBatteryV2)
	go watch(updates, kindBrightness, getBrightnessV2)
	go watchTime(updates)

	state := statusBar{title: getIdentity()}
	lastOutput := ""
	for update := range updates {
		switch update.kind {
		case kindVolume:
			state.volume = update
		case kindFans:
			state.fans = update
		case kindBattery:
			state.battery = update
		case kindBrightness:
			state.brightness = update
		case kindTimeNow:
			state.now = update.value.(time.Time)
		}

		output := state.String()
		if output != lastOutput {
			fmt.Println(output)
			lastOutput = output
		}
	}
}

type kind int

const (
	kindVolume kind = iota + 1
	kindFans
	kindBattery
	kindBrightness
	kindTimeNow
)

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
	case kindTimeNow:
		return "time"
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
	case kindTimeNow:
		return 1 * time.Second
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", u))
}

type statusField struct {
	kind  kind
	value fmt.Stringer
	err   error
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

type statusBar struct {
	title      string
	now        time.Time
	fans       statusField
	volume     statusField
	battery    statusField
	brightness statusField
}

func (s statusBar) String() string {
	timeStr := strings.ToLower(s.now.Format("Monday, Jan 02 > 15:04"))
	return fmt.Sprintf("%s | %s | %s | %s | %s | %s", s.title, s.fans, s.battery, s.brightness, s.volume, timeStr)
}

func watch[T fmt.Stringer](
	ch chan<- statusField,
	kind kind,
	getter func() (T, error),
) {
	interval := updateInterval(kind)
	var lastStr string
	for {
		val, err := getter()
		if err != nil {
			ch <- statusField{
				kind: kind,
				err:  err,
			}
			time.Sleep(interval)
			continue
		}

		s := val.String()
		if s != lastStr {
			ch <- statusField{
				kind:  kind,
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
			ch <- statusField{kind: kindTimeNow, value: now}
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
