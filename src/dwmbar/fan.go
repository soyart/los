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
	if len(f.rpms) != 0 {
		rpms := make([]string, len(f.rpms))
		for i := range f.rpms {
			rpms[i] = fmt.Sprintf("%d", f.rpms[i])
		}
		parts = append(parts, "rpm: "+strings.Join(rpms, " "))
	}
	if len(f.temps) != 0 {
		avg := float64(0)
		for i := range f.temps {
			avg += float64(f.temps[i])
		}
		avg /= float64(len(f.temps))
		parts = append(parts, fmt.Sprintf("temp (avg): %.2f°C", avg))
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
		rpms = append(rpms, rpm)
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
