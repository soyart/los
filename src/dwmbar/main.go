package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	updates := make(chan stateUpdate, 8)

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
			state.volume = update.value.(volume)
		case updateFans:
			state.fans = update.value.(fans)
		case updateBattery:
			state.battery = update.value.(battery)
		case updateBrightness:
			state.brightness = update.value.(brightness)
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

type updateKind int

const (
	updateVolume updateKind = iota + 1
	updateFans
	updateBattery
	updateBrightness
	updateTime
)

func updateInterval(u updateKind) time.Duration {
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
	panic("uncaught updateKind")
}

type stateUpdate struct {
	kind  updateKind
	value any
}

type statusBar struct {
	title      string
	now        time.Time
	fans       fans
	volume     volume
	battery    battery
	brightness brightness
}

func (s statusBar) String() string {
	timeStr := strings.ToLower(s.now.Format("Monday, Jan 02 > 15:04"))
	return fmt.Sprintf("%s | %s | %s | %s | %s | %s", s.title, s.fans, s.battery, s.brightness, s.volume, timeStr)
}

func watch[T fmt.Stringer](
	ch chan<- stateUpdate,
	kind updateKind,
	getter func() (T, error),
) {
	var lastStr string
	for {
		val, _ := getter()
		if s := val.String(); s != lastStr {
			ch <- stateUpdate{kind, val}
			lastStr = s
		}
		time.Sleep(updateInterval(kind))
	}
}

func watchTime(ch chan<- stateUpdate) {
	var lastStr string
	for {
		now := time.Now()
		s := now.Format("Monday, Jan 02 > 15:04")
		if s != lastStr {
			ch <- stateUpdate{updateTime, now}
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
