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

	for {
		status := formatStatus(identity)
		fmt.Println(status)
		time.Sleep(1 * time.Second)
	}
}

// getIdentity returns the "user@host" string from args or environment.
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

// formatStatus builds the complete status line.
func formatStatus(identity string) string {
	now := time.Now()
	timeStr := strings.ToLower(now.Format("Monday, Jan 02 > 15:04"))

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

	parts = append(parts, timeStr)

	return strings.Join(parts, " | ")
}

// readFile reads a sysfs file and returns its trimmed content.
// Returns empty string if the file cannot be read.
func readFile(path string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

// findFirstMatch returns the first path matching the glob pattern.
// Returns empty string if no match is found.
func findFirstMatch(pattern string) string {
	matches, err := filepath.Glob(pattern)
	if err != nil || len(matches) == 0 {
		return ""
	}
	return matches[0]
}

// findAllMatches returns all paths matching the glob pattern.
// Returns nil if no matches are found.
func findAllMatches(pattern string) []string {
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil
	}
	return matches
}
