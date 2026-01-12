package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

type kind int

const (
	kindClock kind = iota + 1
	kindVolume
	kindFans
	kindBattery
	kindBrightness
	kindTemperatures
	kindWifi
)

// kinds returns all supported kinds in display order (matching bar.String)
func kinds() [7]kind {
	return [7]kind{
		kindVolume,
		kindBrightness,
		kindFans,
		kindTemperatures,
		kindWifi,
		kindBattery,
		kindClock,
	}
}

func kindFromString(s string) kind {
	for _, k := range kinds() {
		if s == k.String() {
			return k
		}
	}
	panic("unknown kind string: " + s)
}

func (k kind) String() string {
	switch k {
	case kindClock:
		return "time"
	case kindVolume:
		return "volume"
	case kindFans:
		return "fans"
	case kindBattery:
		return "battery"
	case kindBrightness:
		return "brightness"
	case kindTemperatures:
		return "temperature"
	case kindWifi:
		return "wifi"
	}
	panic("uncaught kind=" + fmt.Sprintf("%d", k))
}

// field represents a state, indentified by kind, and has a value and an error.
// field is displayed as value.String() or err.Error() if err is not nil.
type field struct {
	kind  kind
	value fmt.Stringer
	err   error
}

func (f field) String() string {
	if f.kind == 0 {
		empty := field{}
		if f != empty {
			err := fmt.Errorf("unexpected kind==0 from non-empty field: value=%v, err=%v", f.value, f.err)
			panic(err.Error())
		}
		return "initializing ..."
	}
	if f.err != nil {
		return fmt.Sprintf("%s: %s", f.kind.String(), f.err.Error())
	}
	if f.value != nil {
		return f.value.String()
	}
	return fmt.Sprintf("%s: null", f.kind.String())
}

// states stores field values indexed by kind
type states []field

func newStates() states { return make(states, len(kinds())) }

// key returns 0-based index for array lookup
func (s states) key(k kind) int { return int(k) - 1 }

func (s states) set(k kind, f field) { s[s.key(k)] = f }

func (s states) get(k kind) field {
	idx := s.key(k)
	if idx >= 0 && idx < len(s) {
		return s[idx]
	}
	return field{}
}

// bar defines the status bar current states
type bar struct {
	title   string
	display []kind // fields specify display order, might differ from config.fields (empty config.fields leads to full bar.fields)
	values  states
	updates chan field
}

// run starts the status bar with the given config.
// Is launches multiple goroutines to poll and watch for updates,
// and updates along with displays the bar's internal state.
func (b bar) run(c config) {
	for _, k := range b.display {
		switch k {
		case kindClock:
			go poll(
				b.updates,
				kindClock,
				pollClock(c.Clock.Settings), c.Clock.Interval.Duration())

		case kindVolume:
			go poll(
				b.updates,
				kindVolume,
				pollVolume(c.Volume.Settings), c.Volume.Interval.Duration())

		case kindFans:
			go poll(
				b.updates,
				kindFans,
				pollFans(c.Fans.Settings), c.Fans.Interval.Duration())

		case kindBattery:
			go poll(
				b.updates, kindBattery,
				pollBattery(c.Battery.Settings), c.Battery.Interval.Duration())

		case kindBrightness:
			go poll(
				b.updates,
				kindBrightness,
				pollBrightness(c.Brightness.Settings), c.Brightness.Interval.Duration())

		case kindTemperatures:
			go poll(
				b.updates,
				kindTemperatures,
				pollTemperatures(c.Temperatures.Settings), c.Temperatures.Interval.Duration())

		case kindWifi:
			go poll(
				b.updates,
				kindWifi,
				pollWifi(c.Wifi.Settings), c.Wifi.Interval.Duration())
			go live(
				b.updates,
				kindWifi,
				watchWifi(c.Wifi.Settings))
		}
	}

	// Only print when new change arrives
	// We test string for equality
	lastOutput := ""
	for update := range b.updates {
		b.values.set(update.kind, update)

		output := b.String()
		if output == lastOutput {
			continue
		}
		os.Stdout.Write([]byte(output))
		lastOutput = output
	}
}

func (b bar) String() string {
	var sb strings.Builder
	sb.WriteString(b.title)
	for _, k := range b.display {
		sb.WriteString(" | ")
		sb.WriteString(b.values.get(k).String())
	}
	sb.WriteByte('\n')
	return sb.String()
}

// poller is any simple function that returns a stringer.
// The function is called at interval by [poll].
//
// The return value is mapped to string via its method T.String,
// and the string is used as display value in our status bar.
type poller[T fmt.Stringer] func() (T, error)

// watcher is a function that sends live updates to a channel.
// The watcher owns its lifecycle and sends result[T] updates.
// Unlike pollers, watchers react to external events (e.g., D-Bus signals).
type watcher[T fmt.Stringer] func(chan<- result[T])

type result[T any] struct {
	value T
	err   error
}

// poll uses poller p to poll T at some interval, then wraps T
// with [field] and sends the field through chanel c
func poll[T fmt.Stringer](
	c chan<- field,
	k kind,
	p poller[T],
	interval time.Duration,
) {
	if interval == 0 {
		interval = 1 * time.Second
	}

	var last string
	for {
		val, err := p()
		if err != nil {
			c <- field{
				kind: k,
				err:  err,
			}
			last = err.Error()
			time.Sleep(interval)
			continue
		}

		s := val.String()
		if s != last {
			c <- field{
				kind:  k,
				value: val,
			}
			last = s
		}
		time.Sleep(interval)
	}
}

// live runs a watcher and forwards its results to the main status channel.
// The watcher only knows about its own type T, not kind or [field].
// Deduplication is handled here, same as poll.
func live[T fmt.Stringer](c chan<- field, k kind, w watcher[T]) {
	updates := make(chan result[T], 1)
	go w(updates)

	var last string
	for r := range updates {
		if r.err != nil {
			c <- field{kind: k, err: r.err}
			last = r.err.Error()
			continue
		}

		s := r.value.String()
		if s != last {
			c <- field{kind: k, value: r.value}
			last = s
		}
	}
}

func usernameAtHost() string {
	if len(os.Args) > 1 && os.Args[1] != "" {
		return os.Args[1]
	}
	user := os.Getenv("USER")
	if user == "" {
		user = "unknown"
	}
	host, err := os.Hostname()
	if err != nil {
		host = "unknown"
	}
	return fmt.Sprintf("%s@%s", user, host)
}

func readFile(path string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(data))
}

func findFirstMatch(pattern string) string {
	matches, err := filepath.Glob(pattern)
	if err != nil || len(matches) == 0 {
		return ""
	}
	return matches[0]
}

func findAllMatches(pattern string) []string {
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil
	}
	return matches
}
