package main

import (
	"errors"
	"fmt"
	"path/filepath"
	"strconv"
)

type battery struct {
	percentage uint
	charging   bool
}

func (b battery) String() string {
	if b.charging {
		return fmt.Sprintf("charging: %d%%", b.percentage)
	}
	return fmt.Sprintf("battery: %d%%", b.percentage)
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
		charging:   statusState == "charging",
	}, nil
}
