package main

import "time"

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
	return func() (clock, error) {
		return clock{
			layout: args.Layout,
			now:    time.Now(),
		}, nil
	}
}
