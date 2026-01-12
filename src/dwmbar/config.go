package main

import (
	"encoding/json"
	"fmt"
	"time"
)

const configLocation = ".config/dwmbar/config.json"

type config struct {
	Title        string                         `json:"title"`
	Fields       []string                       `json:"fields"`
	Clock        withInterval[argsClock]        `json:"clock"`
	Volume       withInterval[argsVolume]       `json:"volume"`
	Fans         withInterval[argsFans]         `json:"fans"`
	Temperatures withInterval[argsTemperatures] `json:"temperatures"`
	Battery      withInterval[argsBattery]      `json:"battery"`
	Brightness   withInterval[argsBrightness]   `json:"brightness"`
	Wifi         withInterval[argsWifi]         `json:"wifi"`
}

type withInterval[T any] struct {
	Interval duration `json:"interval"`
	Settings T        `json:"settings"`
}

// duration wraps time.duration with flexible JSON unmarshaling.
// Accepts: "1s", "500ms", "5m" (Go duration strings) or numbers (seconds).
type duration time.Duration

func (d *duration) UnmarshalJSON(b []byte) error {
	var v any
	if err := json.Unmarshal(b, &v); err != nil {
		return err
	}
	switch value := v.(type) {
	case string:
		dur, err := time.ParseDuration(value)
		if err != nil {
			return err
		}
		*d = duration(dur)
	case float64:
		// Interpret as seconds
		*d = duration(time.Duration(value * float64(time.Second)))
	default:
		return fmt.Errorf("invalid duration type: %T", v)
	}
	return nil
}

func (d duration) Duration() time.Duration {
	return time.Duration(d)
}

func configDefault() config {
	return config{
		Title: usernameAtHost(),
		Fields: func() []string {
			all := kinds()
			s := make([]string, len(all))
			for i, k := range all {
				s[i] = k.String()
			}
			return s
		}(),
		Clock: withInterval[argsClock]{
			Interval: duration(1 * time.Second),
			Settings: argsClock{
				// https://go.dev/src/time/format.go
				Layout: defaultClockLayout,
			},
		},
		Volume: withInterval[argsVolume]{
			Interval: duration(200 * time.Millisecond),
			Settings: argsVolume{
				Backend: backendPipewire,
			},
		},
		Fans: withInterval[argsFans]{
			Interval: duration(1 * time.Second),
			Settings: argsFans{
				Cache: true,
				Limit: 2,
			},
		},
		Temperatures: withInterval[argsTemperatures]{
			Interval: duration(5 * time.Second),
			Settings: argsTemperatures{
				Cache:    true,
				Separate: false,
			},
		},
		Battery: withInterval[argsBattery]{
			Interval: duration(5 * time.Second),
			Settings: argsBattery{
				Cache: true,
			},
		},
		Brightness: withInterval[argsBrightness]{
			Interval: duration(500 * time.Millisecond),
			Settings: argsBrightness{
				Cache: true,
			},
		},
		Wifi: withInterval[argsWifi]{
			Interval: duration(30 * time.Second), // Heartbeat interval for signal fallback
			Settings: argsWifi{
				Backend: backendWifiAuto,
			},
		},
	}
}
