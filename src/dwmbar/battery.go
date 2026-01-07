package main

import (
	"fmt"
	"path/filepath"
	"strings"
)

// getBattery reads battery status and capacity from sysfs.
// Returns a formatted string like "discharging: 85%" or empty if no battery.
func getBattery() string {
	// Try BAT0, BAT1, etc.
	batPath := findFirstMatch("/sys/class/power_supply/BAT*")
	if batPath == "" {
		return ""
	}

	status := readFile(filepath.Join(batPath, "status"))
	capacity := readFile(filepath.Join(batPath, "capacity"))

	if status == "" || capacity == "" {
		return ""
	}

	return fmt.Sprintf("%s: %s%%", strings.ToLower(status), capacity)
}

