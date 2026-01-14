package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const (
	choiceOff = "Off"
	choiceOn  = "On"
)

func main() {
	var choice string

	if len(os.Args) > 1 {
		// Direct CLI usage: dmenutrackpad Off
		choice = os.Args[1]
	} else {
		// Interactive: spawn wofi
		var err error
		choice, err = wofiSelect()
		if err != nil {
			fmt.Fprintf(os.Stderr, "wofi: %s\n", err)
			os.Exit(1)
		}
	}

	switch choice {
	case choiceOff:
		if err := setTrackpad(false); err != nil {
			fmt.Fprintf(os.Stderr, "trackpad off: %s\n", err)
			os.Exit(1)
		}
	case choiceOn:
		if err := setTrackpad(true); err != nil {
			fmt.Fprintf(os.Stderr, "trackpad on: %s\n", err)
			os.Exit(1)
		}
	case "":
		// User cancelled wofi selection
		os.Exit(0)
	default:
		fmt.Fprintf(os.Stderr, "expected '%s' or '%s', got '%s'\n", choiceOff, choiceOn, choice)
		os.Exit(1)
	}
}

func wofiSelect() (string, error) {
	cmd := exec.Command("wofi", "-d", "-i", "-p", "Trackpad:")
	cmd.Stdin = strings.NewReader(choiceOff + "\n" + choiceOn + "\n")
	out, err := cmd.Output()
	if err != nil {
		// Exit code 1 means user cancelled - not an error
		if exitErr, ok := err.(*exec.ExitError); ok && exitErr.ExitCode() == 1 {
			return "", nil
		}
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

func setTrackpad(enabled bool) error {
	state := "disabled"
	if enabled {
		state = "enabled"
	}
	cmd := exec.Command("swaymsg", "input", "type:touchpad", "events", state)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
