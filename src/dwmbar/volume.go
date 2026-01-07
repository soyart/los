package main

import (
	"os/exec"
	"strings"

	"github.com/godbus/dbus/v5"
)

// getVolume retrieves the current audio volume.
// Tries D-Bus first, falls back to wpctl if D-Bus fails.
// Returns a string like "0.75" or "0.50 [MUTED]".
func getVolume() string {
	vol := getVolumeDBus()
	if vol != "" {
		return vol
	}
	return getVolumeWpctl()
}

// getVolumeDBus tries to get volume via WirePlumber D-Bus interface.
// WirePlumber doesn't expose a simple D-Bus API for volume queries,
// so this is a placeholder for future implementation.
// For now, it returns empty to trigger the fallback.
func getVolumeDBus() string {
	conn, err := dbus.ConnectSessionBus()
	if err != nil {
		return ""
	}
	defer conn.Close()

	// WirePlumber uses a custom protocol over PipeWire, not a standard D-Bus API.
	// The most reliable D-Bus approach would be through org.freedesktop.portal.Desktop
	// or by implementing the PipeWire wire protocol.
	//
	// For now, we fall back to wpctl which is reliable.
	// TODO: Implement proper PipeWire D-Bus volume query if a stable API becomes available.

	return ""
}

// getVolumeWpctl gets volume by executing wpctl command.
// This is the fallback when D-Bus is unavailable or fails.
func getVolumeWpctl() string {
	out, err := exec.Command("wpctl", "get-volume", "@DEFAULT_SINK@").Output()
	if err != nil {
		return ""
	}

	// Output format: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
	output := strings.TrimSpace(string(out))
	parts := strings.Fields(output)

	if len(parts) < 2 {
		return ""
	}

	// parts[0] = "Volume:", parts[1] = "0.50", parts[2] = "[MUTED]" (optional)
	volume := parts[1]
	if len(parts) >= 3 && parts[2] == "[MUTED]" {
		volume += " [MUTED]"
	}

	return volume
}

