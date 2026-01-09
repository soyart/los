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

func getBatteryV2() (battery, error) {
	path := findFirstMatch("/sys/class/power_supply/BAT*")
	if path == "" {
		return battery{}, errors.New("no battery path")
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
