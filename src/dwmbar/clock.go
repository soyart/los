package main

import "time"

const defaultClockLayout = "Monday, Jan 02 > 15:04"

type clock struct {
	now    time.Time
	layout string
}

type argsClock struct {
	Layout string `json:"layout"`
}

func (c clock) String() string {
	return c.now.Format(c.layout)
}

func pollClock(args argsClock) poller[clock] {
	layout := args.Layout
	if layout == "" {
		layout = defaultClockLayout
	}
	return func() (clock, error) {
		return clock{
			layout: layout,
			now:    time.Now(),
		}, nil
	}
}
