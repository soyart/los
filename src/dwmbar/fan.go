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

func getFansV3() getter[fans] {
	paths := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")
	g, err := cache(paths, getFans)
	if err != nil {
		panic(err.Error())
	}
	return g
}

func getFansAndTempV2() (fans, error) {
	fanFiles := findAllMatches("/sys/class/hwmon/hwmon*/fan*_input")
	tempFiles := findAllMatches("/sys/class/hwmon/hwmon*/temp*_input")
	return getFansAndTemps(fanFiles, tempFiles)
}

func getFansAndTemps(fanPaths []string, temperatures []string) (fans, error) {
	rpms := make([]uint64, 0, len(fanPaths))
	for _, fanFile := range fanPaths {
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

	temps := make([]int, 0, len(temperatures))
	for _, tempFile := range temperatures {
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

func getFans(fanPaths []string) (fans, error) {
	rpms := make([]uint64, 0, len(fanPaths))
	for _, fanFile := range fanPaths {
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
	return fans{rpms: rpms, temps: nil}, nil
}
