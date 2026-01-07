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
		status := formatStatus(identity, now)
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

// formatStatus builds the status line.
// Example: "user@host | rpm: 2500 | discharging: 85% | bright: 500/1000 | 0.75 | monday, jan 08 > 14:30"
func formatStatus(identity string, now time.Time) string {
	parts := []string{
		identity,
	}
	if fan := getFanRPM(); fan != "" {
		parts = append(parts, fan)
	}
	if batt := getBattery(); batt != "" {
		parts = append(parts, batt)
	}
	if bright := getBrightness(); bright != "" {
		parts = append(parts, bright)
	}
	if vol := getVolume(); vol != "" {
		parts = append(parts, vol)
	}
	parts = append(parts, strings.ToLower(now.Format("Monday, Jan 02 > 15:04")))
	return strings.Join(parts, " | ")
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
