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

type argsBrightness struct {
	Cache bool `json:"cache"`
}

func (b brightness) String() string {
	return fmt.Sprintf("bright: %.2f%%", float64(b.value)/float64(b.max)*100.0)
}

func getterBrightness(args argsBrightness) getter[brightness] {
	const pattern = "/sys/class/backlight/*"
	if args.Cache {
		path := findFirstMatch(pattern)
		return func() (brightness, error) {
			return getBrightness(path)
		}
	}
	return func() (brightness, error) {
		path := findFirstMatch(pattern)
		return getBrightness(path)
	}
}

func getBrightness(path string) (brightness, error) {
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
