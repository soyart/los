package main

const configLocation = ".config/dwmbar/config.json"

type config struct {
	Title        string           `json:"title"`
	Clock        argsClock        `json:"clock"`
	Fans         argsFans         `json:"fans"`
	Temperatures argsTemperatures `json:"temperatures"`
	Battery      argsBattery      `json:"battery"`
	Brightness   argsBrightness   `json:"brightness"`
}

func configDefault() config {
	return config{
		Title: usernameAtHost(),
		Clock: argsClock{
			Layout: "Monday, Jan 02 > 15:04", // https://go.dev/src/time/format.go
		},
		Fans: argsFans{
			Cache: true,
			Limit: 2,
		},
		Temperatures: argsTemperatures{
			Cache:    true,
			Separate: false,
		},
		Battery: argsBattery{
			Cache: true,
		},
		Brightness: argsBrightness{
			Cache: true,
		},
	}
}
