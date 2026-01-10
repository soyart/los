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

type argsFans struct {
	cache bool
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

func getterFans(args argsFans) getter[fans] {
	const pattern = "/sys/class/hwmon/hwmon*/fan*_input"
	if args.cache {
		cachedPaths := findAllMatches(pattern)
		return func() (fans, error) {
			return getFans(cachedPaths)
		}
	}
	return func() (fans, error) {
		cachedPaths := findAllMatches(pattern)
		return getFans(cachedPaths)
	}
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
