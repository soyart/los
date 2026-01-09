package main

import (
	"fmt"
	"strconv"
)

type temperature struct {
	temps []int
}

func (f temperature) String() string {
	if len(f.temps) == 0 {
		return "null"
	}
	avg := float64(0)
	for i := range f.temps {
		avg += float64(f.temps[i])
	}
	avg /= float64(len(f.temps))
	return fmt.Sprintf("temperature: %.2f°C", avg)
}

func getTemperaturesCached() getter[temperature] {
	return cache(
		findAllMatches("/sys/class/hwmon/hwmon*/temp*_input"),
		getTemperatures,
	)
}

func getTemperatures(temperatures []string) (temperature, error) {
	temps := make([]int, 0, len(temperatures))
	for _, tempFile := range temperatures {
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
	return temperature{temps: temps}, nil
}
