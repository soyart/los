package main

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/godbus/dbus/v5"
)

// getVolume returns audio volume. Tries D-Bus, falls back to wpctl.
// Example: "0.75" or "0.50 [MUTED]"
func getVolume() string {
	vol, err := getVolumeDBus()
	if err == nil && vol != "" {
		return vol
	}
	return getVolumeWpctl()
}

// getVolumeDBus queries PulseAudio D-Bus interface (PipeWire compatible).
func getVolumeDBus() (string, error) {
	conn, err := dbus.ConnectSessionBus()
	if err != nil {
		return "", fmt.Errorf("session bus: %w", err)
	}
	defer conn.Close()

	pulseObj := conn.Object("org.PulseAudio1", "/org/pulseaudio/core1")

	var sinkPath dbus.ObjectPath
	err = pulseObj.Call("org.freedesktop.DBus.Properties.Get", 0,
		"org.PulseAudio.Core1", "FallbackSink").Store(&sinkPath)
	if err != nil {
		return "", fmt.Errorf("get sink: %w", err)
	}

	sinkObj := conn.Object("org.PulseAudio1", sinkPath)

	var volume []uint32
	err = sinkObj.Call("org.freedesktop.DBus.Properties.Get", 0,
		"org.PulseAudio.Core1.Device", "Volume").Store(&volume)
	if err != nil {
		return "", fmt.Errorf("get volume: %w", err)
	}

	var muted bool
	err = sinkObj.Call("org.freedesktop.DBus.Properties.Get", 0,
		"org.PulseAudio.Core1.Device", "Mute").Store(&muted)
	if err != nil {
		return "", fmt.Errorf("get mute: %w", err)
	}

	if len(volume) == 0 {
		return "", fmt.Errorf("no channels")
	}

	// PA volume: 0-65536 (100% = 65536)
	avgVolume := uint32(0)
	for _, v := range volume {
		avgVolume += v
	}
	avgVolume /= uint32(len(volume))
	normalizedVol := float64(avgVolume) / 65536.0

	result := fmt.Sprintf("%.2f", normalizedVol)
	if muted {
		result += " [MUTED]"
	}

	return result, nil
}

// getVolumeWpctl queries volume via wpctl command.
func getVolumeWpctl() string {
	out, err := exec.Command("wpctl", "get-volume", "@DEFAULT_SINK@").Output()
	if err != nil {
		return ""
	}

	// Example: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
	output := strings.TrimSpace(string(out))
	parts := strings.Fields(output)

	if len(parts) < 2 {
		return ""
	}

	volume := parts[1]
	if len(parts) >= 3 && parts[2] == "[MUTED]" {
		volume += " [MUTED]"
	}

	return volume
}
