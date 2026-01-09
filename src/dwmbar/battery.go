package main

import (
	"errors"
	"fmt"
	"path/filepath"
	"strconv"
	"strings"
)

type battery struct {
	percentage uint
	status     string
}

func (b battery) String() string {
	if b.status == "" {
		return fmt.Sprintf("battery(unknown): %d%%", b.percentage)
	}
	return fmt.Sprintf("battery(%s): %d%%", b.status, b.percentage)
}

func getBatteryCached() getter[battery] {
	return cache(
		findFirstMatch("/sys/class/power_supply/BAT*"),
		getBattery,
	)
}

func getBatteryV2() (battery, error) {
	return getBattery(
		findFirstMatch("/sys/class/power_supply/BAT*"),
	)
}

func getBattery(path string) (battery, error) {
	if path == "" {
		return battery{}, errors.New("empty battery path")
	}
	capacityState := readFile(filepath.Join(path, "capacity"))
	percent, err := strconv.ParseInt(capacityState, 10, 32)
	if err != nil {
		return battery{}, err
	}
	statusState := readFile(filepath.Join(path, "status"))
	return battery{
		percentage: uint(percent),
		status:     strings.ToLower(statusState),
	}, nil
}
