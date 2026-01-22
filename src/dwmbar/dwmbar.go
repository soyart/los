package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// kind is our enum for field types
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

// field represents a state, identified by kind, and has a value and an error.
// field is displayed as value.String() or err.Error() if err is not nil.
type field struct {
	kind  kind
	value fmt.Stringer
	err   error
}

// String returns the display string representation of f
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
	if f.value == nil {
		return fmt.Sprintf("%s: null", f.kind.String())
	}
	return f.value.String()
}

type states []field // actual values display

func (s states) set(data field) {
	for i := range s {
		if data.kind == s[i].kind {
			s[i] = data
			return
		}
	}
}

func newStates(display []kind) states {
	s := make([]field, len(display))
	for i := range s {
		s[i].kind = display[i]
	}
	return s
}

// bar defines the status bar current states
type bar struct {
	title  string
	values states
}

func (b bar) String() string {
	var s strings.Builder
	s.WriteString(b.title)
	for _, f := range b.values {
		s.WriteString(" | ")
		s.WriteString(f.String())
	}
	s.WriteByte('\n')
	return s.String()
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
// with [field] and sends the field through channel c
func poll[T fmt.Stringer](
	k kind,
	c chan<- field,
	p poller[T],
	interval time.Duration,
) {
	if interval == 0 {
		interval = 1 * time.Second
	}

	var last string
	for {
		result, err := p()
		if err != nil {
			c <- field{
				kind: k,
				err:  err,
			}
			last = err.Error()
			time.Sleep(interval)
			continue
		}
		s := result.String()
		if s != last {
			c <- field{
				kind:  k,
				value: result,
			}
			last = s
		}
		time.Sleep(interval)
	}
}

// live runs a watcher and forwards its results to the main status channel.
// The watcher only knows about its own type T, not kind or [field].
// Deduplication is handled here, same as poll.
func live[T fmt.Stringer](
	k kind,
	c chan<- field,
	w watcher[T],
) {
	updates := make(chan result[T], 1)
	go w(updates)

	var last string
	for r := range updates {
		if r.err != nil {
			c <- field{
				kind: k,
				err:  r.err,
			}
			last = r.err.Error()
			continue
		}
		s := r.value.String()
		if s != last {
			c <- field{
				kind:  k,
				value: r.value,
			}
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

func kindFromString(s string) kind {
	for _, k := range kinds() {
		if s == k.String() {
			return k
		}
	}
	panic("unknown kind string: " + s)
}

func kindsFromStrings(names []string) []kind {
	result := make([]kind, len(names))
	for i := range names {
		result[i] = kindFromString(names[i])
	}
	return result
}

func kindStrings(kinds []kind) []string {
	results := make([]string, len(kinds))
	for i := range kinds {
		results[i] = kinds[i].String()
	}
	return results
}
