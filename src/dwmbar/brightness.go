package main

import (
	"fmt"
	"path/filepath"
	"strconv"
)

type brightness struct {
	value uint
	max   uint
}

func (b brightness) String() string {
	return fmt.Sprintf("bright: %d/%d", b.value, b.max)
}

func getBrightnessV2() (brightness, error) {
	path := findFirstMatch("/sys/class/backlight/*")
	if path == "" {
		return brightness{}, fmt.Errorf("")
	}
	valueState := readFile(filepath.Join(path, "brightness"))
	if valueState == "" {
		return brightness{}, fmt.Errorf("valueState is empty")
	}
	maxState := readFile(filepath.Join(path, "max_brightness"))
	if maxState == "" {
		return brightness{}, fmt.Errorf("maxState is empty")
	}
	value, err := strconv.ParseUint(valueState, 10, 64)
	if err != nil {
		return brightness{}, fmt.Errorf("failed to parse valueState uint from '%s': %w", valueState, err)
	}
	max, err := strconv.ParseUint(maxState, 10, 64)
	if err != nil {
		return brightness{}, fmt.Errorf("failed to parse maxState uint from '%s': %w", valueState, err)
	}
	return brightness{
		value: uint(value),
		max:   uint(max),
	}, nil
}
