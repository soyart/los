package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	identity := getIdentity()
	lastStatus := ""
	for {
		now := time.Now()
		bar, err := getStatusBar(identity, now)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			time.Sleep(1 * time.Second)
			continue
		}
		status := bar.String()
		if status != lastStatus {
			fmt.Println(status)
			lastStatus = status
		}
		time.Sleep(1 * time.Second)
	}
}

// getIdentity returns "user@host" from args or environment.
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

func getStatusBar(title string, now time.Time) (statusBar, error) {
	volume, err := getVolumeV2()
	if err != nil {
		return statusBar{}, err
	}
	fans, err := getFansV2()
	if err != nil {
		return statusBar{}, err
	}
	battery, err := getBatteryV2()
	if err != nil {
		return statusBar{}, err
	}
	brightness, err := getBrightnessV2()
	if err != nil {
		return statusBar{}, err
	}
	return statusBar{
		title:      title,
		now:        now,
		volume:     volume,
		fans:       fans,
		battery:    battery,
		brightness: brightness,
	}, nil
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
