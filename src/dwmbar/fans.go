package main

import (
	"bytes"
	"fmt"
	"strconv"
)

type fans struct {
	rpms  []uint32 // rpms stores RPMs of <limit> fans
	limit uint16   // limit defines max number of fans to show on the status bar
}

type argsFans struct {
	Cache bool   `json:"cache"`
	Limit uint16 `json:"limit"`
}

func (f fans) String() string {
	if len(f.rpms) == 0 {
		return "rpm: no data"
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

func getFans(fanPaths []string, limitConfig uint16) (fans, error) {
	limit := int(limitConfig)
	if limit <= 0 {
		limit = len(fanPaths)
	}
	rpms := make([]uint32, limitConfig)
	for i, fanFile := range fanPaths {
		if i >= limit {
			break
		}
		state := readFile(fanFile)
		if state == "" {
			continue
		}
		rpm, err := strconv.ParseUint(state, 10, 32)
		if err != nil {
			return fans{}, fmt.Errorf("failed to parse rpm '%s': %w", state, err)
		}
		rpms[i] = uint32(rpm)
	}
	return fans{rpms: rpms}, nil
}
