package main

import (
	"fmt"
	"path/filepath"
)

// getBrightness reads screen brightness from sysfs.
// Returns a formatted string like "bright: 500/1000" or empty if unavailable.
func getBrightness() string {
	// Find first backlight device
	blPath := findFirstMatch("/sys/class/backlight/*")
	if blPath == "" {
		return ""
	}

	current := readFile(filepath.Join(blPath, "brightness"))
	max := readFile(filepath.Join(blPath, "max_brightness"))

	if current == "" || max == "" {
		return ""
	}

	return fmt.Sprintf("bright: %s/%s", current, max)
}

