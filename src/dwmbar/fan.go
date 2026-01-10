package main

import (
	"fmt"
	"strconv"
	"strings"
)

type fans struct {
	rpms  []uint64
	temps []int // degrees Celsius
	limit int   // limit defines max number of fans to show on the status bar
}

type argsFans struct {
	Cache bool `json:"cache"`
	Limit int  `json:"limit"`
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
	if args.Cache {
		cachedPaths := findAllMatches(pattern)
		return func() (fans, error) {
			return getFans(cachedPaths, args.Limit)
		}
	}
	return func() (fans, error) {
		cachedPaths := findAllMatches(pattern)
		return getFans(cachedPaths, args.Limit)
	}
}

func getFans(fanPaths []string, limit int) (fans, error) {
	if limit <= 0 {
		limit = len(fanPaths)
	}
	rpms := make([]uint64, 0, limit)
	for i, fanFile := range fanPaths {
		if i >= limit {
			break
		}
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
