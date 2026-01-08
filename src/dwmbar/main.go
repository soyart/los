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

	go watch(updates, updateVolume, getVolumeV2)
	go watch(updates, updateFans, getFansV2)
	go watch(updates, updateBattery, getBatteryV2)
	go watch(updates, updateBrightness, getBrightnessV2)
	go watchTime(updates)

	state := statusBar{title: getIdentity()}
	lastOutput := ""
	for update := range updates {
		switch update.kind {
		case updateVolume:
			state.volume = update
		case updateFans:
			state.fans = update
		case updateBattery:
			state.battery = update
		case updateBrightness:
			state.brightness = update
		case updateTime:
			state.now = update.value.(time.Time)
		}

		output := state.String()
		if output != lastOutput {
			fmt.Println(output)
			lastOutput = output
		}
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

type kind int

const (
	updateVolume kind = iota + 1
	updateFans
	updateBattery
	updateBrightness
	updateTime
)

func (u kind) String() string {
	switch u {
	case updateVolume:
		return "volume"
	case updateFans:
		return "fans"
	case updateBattery:
		return "battery"
	case updateBrightness:
		return "brightness"
	case updateTime:
		return "time"
	}
	panic("uncaught updateKind: " + fmt.Sprintf("%d", u))
}

func updateInterval(u kind) time.Duration {
	switch u {
	case updateVolume:
		return 200 * time.Millisecond
	case updateFans:
		return 1 * time.Second
	case updateBattery:
		return 5 * time.Second
	case updateBrightness:
		return 500 * time.Millisecond
	case updateTime:
		return 1 * time.Second
	}
	panic("uncaught updateKind: " + fmt.Sprintf("%d", u))
}

type field interface {
	String() string
}

type statusField struct {
	kind  kind
	value field
	err   error
}

func (s statusField) String() string {
	if s.err != nil {
		return fmt.Sprintf("%s: %s", s.kind.String(), s.err.Error())
	}
	if s.value == nil {
		return fmt.Sprintf("%s: null", s.kind.String())
	}
	return s.value.String()
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
	var lastStr string
	for {
		val, err := getter()
		if err != nil {
			ch <- statusField{kind: kind, err: err}
		}
		if s := val.String(); s != lastStr {
			ch <- statusField{kind: kind, value: val}
			lastStr = s
		}
		time.Sleep(updateInterval(kind))
	}
}

func watchTime(ch chan<- statusField) {
	var lastStr string
	for {
		now := time.Now()
		s := now.Format("Monday, Jan 02 > 15:04")
		if s != lastStr {
			ch <- statusField{kind: updateTime, value: now}
			lastStr = s
		}
		time.Sleep(1 * time.Second)
	}
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
