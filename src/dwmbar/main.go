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

	go watchVolume(updates)
	go watchFans(updates)
	go watchBattery(updates)
	go watchBrightness(updates)
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
	updateVolume updateKind = iota
	updateFans
	updateBattery
	updateBrightness
	updateTime
)

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

func watchVolume(ch chan<- stateUpdate) {
	var lastStr string
	for {
		v, _ := getVolumeV2()
		if s := v.String(); s != lastStr {
			ch <- stateUpdate{updateVolume, v}
			lastStr = s
		}
		time.Sleep(200 * time.Millisecond)
	}
}

func watchFans(ch chan<- stateUpdate) {
	var lastStr string
	for {
		f, _ := getFansV2()
		if s := f.String(); s != lastStr {
			ch <- stateUpdate{updateFans, f}
			lastStr = s
		}
		time.Sleep(1 * time.Second)
	}
}

func watchBattery(ch chan<- stateUpdate) {
	var lastStr string
	for {
		b, _ := getBatteryV2()
		if s := b.String(); s != lastStr {
			ch <- stateUpdate{updateBattery, b}
			lastStr = s
		}
		time.Sleep(5 * time.Second)
	}
}

func watchBrightness(ch chan<- stateUpdate) {
	var lastStr string
	for {
		b, _ := getBrightnessV2()
		if s := b.String(); s != lastStr {
			ch <- stateUpdate{updateBrightness, b}
			lastStr = s
		}
		time.Sleep(500 * time.Millisecond)
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
