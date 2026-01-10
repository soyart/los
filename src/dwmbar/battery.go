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

type argsBattery struct {
	Cache bool `json:"cache"`
}

func (b battery) String() string {
	if b.status == "" {
		return fmt.Sprintf("battery(unknown): %d%%", b.percentage)
	}
	return fmt.Sprintf("battery(%s): %d%%", b.status, b.percentage)
}

func getterBattery(args argsBattery) getter[battery] {
	const pattern = "/sys/class/power_supply/BAT*"
	if args.Cache {
		cachedPath := findFirstMatch(pattern)
		return func() (battery, error) {
			return getBattery(cachedPath)
		}
	}
	return func() (battery, error) {
		path := findFirstMatch(pattern)
		return getBattery(path)
	}
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
