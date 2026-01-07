package main

import (
	"fmt"
)

// getFanRPM returns fan speed.
// Example: "rpm: 2500"
func getFanRPM() string {
	fanFiles := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")

	for _, fanFile := range fanFiles {
		rpm := readFile(fanFile)
		if rpm != "" && rpm != "0" {
			return fmt.Sprintf("rpm: %s", rpm)
		}
	}

	return ""
}
