package main

import (
	"fmt"
	"path/filepath"
	"strings"
)

// getBattery returns battery status.
// Example: "discharging: 85%"
func getBattery() string {
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
