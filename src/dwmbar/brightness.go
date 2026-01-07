package main

import (
	"fmt"
	"path/filepath"
)

// getBrightness returns screen brightness.
// Example: "bright: 500/1000"
func getBrightness() string {
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
