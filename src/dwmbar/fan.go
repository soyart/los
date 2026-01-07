package main

import (
	"fmt"
)

// getFanRPM reads fan speed from hwmon sysfs entries.
// Returns a formatted string like "rpm: 2500" or empty if no fan data.
func getFanRPM() string {
	// Find all fan input files across hwmon devices
	fanFiles := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")

	for _, fanFile := range fanFiles {
		rpm := readFile(fanFile)
		if rpm != "" && rpm != "0" {
			return fmt.Sprintf("rpm: %s", rpm)
		}
	}

	return ""
}

