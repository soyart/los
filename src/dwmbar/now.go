package main

import "time"

type clock struct {
	now    time.Time
	layout string
}

type argsClock struct {
	layout string
}

func (c clock) String() string {
	return c.now.Format(c.layout)
}

func getterClock(args argsClock) getter[clock] {
	return func() (clock, error) {
		return clock{
			layout: args.layout,
			now:    time.Now(),
		}, nil
	}
}
