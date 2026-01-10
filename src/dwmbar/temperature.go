package main

import (
	"bytes"
	"fmt"
	"strconv"
)

type temperature struct {
	temps    []int
	separate bool
}

type argsTemperatures struct {
	cache    bool
	separate bool
}

func (f temperature) String() string {
	if len(f.temps) == 0 {
		return "null"
	}

	if f.separate {
		s := new(bytes.Buffer)
		s.WriteString("temperatures:")
		// Try to make it compact for multi-core machines
		for i, temp := range f.temps {
			fmt.Fprintf(s, " cpus[%d]:%d", i, temp)
		}
		return s.String()
	}

	avg := float64(0)
	for i := range f.temps {
		avg += float64(f.temps[i])
	}
	avg /= float64(len(f.temps))
	return fmt.Sprintf("temperature(avg): %.2f°C", avg)
}

func getterTemperatures(args argsTemperatures) getter[temperature] {
	const pattern = "/sys/class/hwmon/hwmon*/temp*_input"
	if args.cache {
		paths := findAllMatches(pattern)
		return func() (temperature, error) {
			return getTemperatures(paths, args.separate)
		}
	}
	return func() (temperature, error) {
		paths := findAllMatches(pattern)
		return getTemperatures(paths, args.separate)
	}
}

func getTemperatures(paths []string, merge bool) (temperature, error) {
	temps := make([]int, 0, len(paths))
	for _, tempFile := range paths {
		state := readFile(tempFile)
		if state == "" {
			continue
		}
		millidegrees, err := strconv.Atoi(state)
		if err != nil {
			return temperature{}, fmt.Errorf("failed to parse temp '%s': %w", state, err)
		}
		if millidegrees > 0 {
			temps = append(temps, millidegrees/1000)
		}
	}
	return temperature{temps: temps, separate: merge}, nil
}
