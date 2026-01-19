package main

import (
	"bytes"
	"fmt"
	"strconv"
)

type fans struct {
	rpms  []uint64
	limit int // limit defines max number of fans to show on the status bar
}

type argsFans struct {
	Cache bool `json:"cache"`
	Limit int  `json:"limit"`
}

func (f fans) String() string {
	if len(f.rpms) == 0 {
		return ""
	}
	result := bytes.NewBufferString("rpm: ")
	for _, r := range f.rpms {
		fmt.Fprintf(result, " %d", r)
	}
	return result.String()
}

func pollFans(args argsFans) poller[fans] {
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
	return fans{rpms: rpms}, nil
}
