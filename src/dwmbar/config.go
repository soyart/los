package main

import "time"

const configLocation = ".config/dwmbar/config.json"

type config struct {
	Title        string                         `json:"title"`
	Clock        withInterval[argsClock]        `json:"clock"`
	Volume       withInterval[argsVolume]       `json:"volume"`
	Fans         withInterval[argsFans]         `json:"fans"`
	Temperatures withInterval[argsTemperatures] `json:"temperatures"`
	Battery      withInterval[argsBattery]      `json:"battery"`
	Brightness   withInterval[argsBrightness]   `json:"brightness"`
}

type withInterval[T any] struct {
	Interval time.Duration `json:"interval"`
	Settings T             `json:"settings"`
}

func configDefault() config {
	return config{
		Title: usernameAtHost(),
		Clock: withInterval[argsClock]{
			Interval: 1 * time.Second,
			Settings: argsClock{
				// https://go.dev/src/time/format.go
				Layout: "Monday, Jan 02 > 15:04",
			},
		},
		Volume: withInterval[argsVolume]{
			Interval: 1 * time.Second,
			Settings: argsVolume{
				Backend: backendPipewire,
			},
		},
		Fans: withInterval[argsFans]{
			Interval: 1 * time.Second,
			Settings: argsFans{
				Cache: true,
				Limit: 2,
			},
		},
		Temperatures: withInterval[argsTemperatures]{
			Interval: 1 * time.Second,
			Settings: argsTemperatures{
				Cache:    true,
				Separate: false,
			},
		},
		Battery: withInterval[argsBattery]{
			Interval: 1 * time.Second,
			Settings: argsBattery{
				Cache: true,
			},
		},
		Brightness: withInterval[argsBrightness]{
			Interval: 1 * time.Second,
			Settings: argsBrightness{
				Cache: true,
			},
		},
	}
}
