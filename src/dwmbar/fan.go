package main

import (
	"fmt"
	"strconv"
	"strings"
)

type fans struct {
	rpms []uint64
}

func (f fans) String() string {
	rpms := make([]string, len(f.rpms))
	for i := range f.rpms {
		rpms[i] = fmt.Sprintf("%d", f.rpms[i])
	}
	return strings.Join(rpms, " ")
}

func getFansV2() (fans, error) {
	fanFiles := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")
	rpms := make([]uint64, len(fanFiles))
	for i := range fanFiles {
		state := readFile(fanFiles[i])
		if state == "" {
			continue
		}
		rpm, err := strconv.ParseUint(state, 10, 32)
		if err != nil {
			return fans{}, fmt.Errorf("failed to parse rpm sysfs state '%s' to float: %w", state, err)
		}
		rpms[i] = rpm
	}
	return fans{rpms: rpms}, nil
}

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
