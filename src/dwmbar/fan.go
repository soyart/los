package main

import (
	"fmt"
	"strconv"
	"strings"
)

type fans struct {
	rpms  []uint64
	temps []int // degrees Celsius
}

func (f fans) String() string {
	parts := []string{}
	if len(f.rpms) > 0 {
		rpms := make([]string, len(f.rpms))
		for i := range f.rpms {
			rpms[i] = fmt.Sprintf("%d", f.rpms[i])
		}
		parts = append(parts, "rpm: "+strings.Join(rpms, " "))
	}
	if len(f.temps) > 0 {
		temps := make([]string, len(f.temps))
		for i := range f.temps {
			temps[i] = fmt.Sprintf("%d°C", f.temps[i])
		}
		parts = append(parts, "temp: "+strings.Join(temps, " "))
	}
	return strings.Join(parts, " | ")
}

func getFansV2() (fans, error) {
	fanFiles := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")
	rpms := make([]uint64, 0, len(fanFiles))
	for _, fanFile := range fanFiles {
		state := readFile(fanFile)
		if state == "" {
			continue
		}
		rpm, err := strconv.ParseUint(state, 10, 64)
		if err != nil {
			return fans{}, fmt.Errorf("failed to parse rpm '%s': %w", state, err)
		}
		if rpm > 0 {
			rpms = append(rpms, rpm)
		}
	}

	tempFiles := findAllMatches("/sys/class/hwmon/hwmon*/temp*_input")
	temps := make([]int, 0, len(tempFiles))
	for _, tempFile := range tempFiles {
		state := readFile(tempFile)
		if state == "" {
			continue
		}
		millidegrees, err := strconv.Atoi(state)
		if err != nil {
			return fans{}, fmt.Errorf("failed to parse temp '%s': %w", state, err)
		}
		if millidegrees > 0 {
			temps = append(temps, millidegrees/1000)
		}
	}

	return fans{rpms: rpms, temps: temps}, nil
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

// getCPUTemp returns CPU temperature.
// Example: "temp: 45°C"
func getCPUTemp() string {
	tempFiles := findAllMatches("/sys/class/hwmon/hwmon*/temp*_input")

	for _, tempFile := range tempFiles {
		raw := readFile(tempFile)
		if raw == "" {
			continue
		}
		millidegrees, err := strconv.Atoi(raw)
		if err != nil || millidegrees == 0 {
			continue
		}
		// Convert millidegrees to degrees
		return fmt.Sprintf("temp: %d°C", millidegrees/1000)
	}

	return ""
}
