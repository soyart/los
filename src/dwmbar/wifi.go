package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/godbus/dbus/v5"
)

const (
	backendIwd            = "iwd"
	backendNetworkManager = "networkmanager"
	backendWifiAuto       = "auto"
)

type wifi struct {
	iface     string
	ssid      string
	connected bool
}

type argsWifi struct {
	Backend string `json:"backend"`
}

func (w wifi) String() string {
	if !w.connected {
		return "wifi(disconnected)"
	}
	return fmt.Sprintf("wifi(%s): %s", w.iface, w.ssid)
}

// watchWifi watches for WiFi state changes via D-Bus signals.
// It sends updates to the channel when the connection state changes.
// Falls back to polling if signals aren't available.
func watchWifi(ch chan<- statusField, args argsWifi, fallbackInterval time.Duration) {
	switch args.Backend {
	case backendIwd:
		watchWifiIwd(ch, fallbackInterval)
	case backendNetworkManager:
		watchWifiNetworkManager(ch, fallbackInterval)
	default:
		// Fall back to NetworkManager
		if err := watchWifiIwd(ch, fallbackInterval); err != nil {
			watchWifiNetworkManager(ch, fallbackInterval)
		}
	}
}

// watchWifiIwd watches WiFi via iwd D-Bus with signal subscription
func watchWifiIwd(ch chan<- statusField, fallbackInterval time.Duration) error {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return fmt.Errorf("system bus: %w", err)
	}
	// Note: connection kept open for the lifetime of the program

	// Subscribe to PropertiesChanged signals from iwd
	if err := conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchPathNamespace("/net/connman/iwd"),
	); err != nil {
		conn.Close()
		return fmt.Errorf("add match signal: %w", err)
	}

	signals := make(chan *dbus.Signal, 10)
	conn.Signal(signals)

	// Get and send initial state
	w, err := getWifiIwdWithConn(conn)
	sendWifiUpdate(ch, w, err)
	lastState := w.String()

	// Heartbeat ticker for fallback polling
	ticker := time.NewTicker(fallbackInterval)
	defer ticker.Stop()

	for {
		select {
		case sig := <-signals:
			// Check if this is a relevant signal (Station interface)
			if len(sig.Body) >= 1 {
				ifaceName, ok := sig.Body[0].(string)
				if ok && (ifaceName == "net.connman.iwd.Station" ||
					ifaceName == "net.connman.iwd.Network") {
					// State changed, get fresh status
					w, err = getWifiIwdWithConn(conn)
					newState := w.String()
					if newState != lastState {
						sendWifiUpdate(ch, w, err)
						lastState = newState
					}
				}
			}
		case <-ticker.C:
			// Heartbeat: poll to catch any missed signals
			w, err = getWifiIwdWithConn(conn)
			newState := w.String()
			if newState != lastState {
				sendWifiUpdate(ch, w, err)
				lastState = newState
			}
		}
	}
}

// watchWifiNetworkManager watches WiFi via NetworkManager D-Bus with signal subscription
func watchWifiNetworkManager(ch chan<- statusField, fallbackInterval time.Duration) error {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return fmt.Errorf("system bus: %w", err)
	}
	// Note: connection kept open for the lifetime of the program

	// Subscribe to StateChanged and PropertiesChanged signals
	if err := conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchPathNamespace("/org/freedesktop/NetworkManager"),
	); err != nil {
		conn.Close()
		return fmt.Errorf("add match signal: %w", err)
	}

	signals := make(chan *dbus.Signal, 10)
	conn.Signal(signals)

	// Get and send initial state
	w, err := getWifiNetworkManagerWithConn(conn)
	sendWifiUpdate(ch, w, err)
	lastState := w.String()

	// Heartbeat ticker for fallback polling
	ticker := time.NewTicker(fallbackInterval)
	defer ticker.Stop()

	for {
		select {
		case sig := <-signals:
			// Check if relevant (Device or AccessPoint changes)
			if len(sig.Body) >= 1 {
				ifaceName, ok := sig.Body[0].(string)
				if ok && (strings.Contains(ifaceName, "Device") ||
					strings.Contains(ifaceName, "AccessPoint") ||
					strings.Contains(ifaceName, "Connection")) {
					w, err = getWifiNetworkManagerWithConn(conn)
					newState := w.String()
					if newState != lastState {
						sendWifiUpdate(ch, w, err)
						lastState = newState
					}
				}
			}
		case <-ticker.C:
			// Heartbeat: poll to catch any missed signals
			w, err = getWifiNetworkManagerWithConn(conn)
			newState := w.String()
			if newState != lastState {
				sendWifiUpdate(ch, w, err)
				lastState = newState
			}
		}
	}
}

func sendWifiUpdate(ch chan<- statusField, w wifi, err error) {
	if err != nil {
		ch <- statusField{kind: kindWifi, err: err}
		return
	}
	ch <- statusField{kind: kindWifi, value: w}
}

// getWifiIwdWithConn gets WiFi status using an existing connection
func getWifiIwdWithConn(conn *dbus.Conn) (wifi, error) {
	iwd := conn.Object("net.connman.iwd", "/")
	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err := iwd.Call("org.freedesktop.DBus.ObjectManager.GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return wifi{}, fmt.Errorf("get managed objects: %w", err)
	}

	for path, interfaces := range objects {
		stationProps, hasStation := interfaces["net.connman.iwd.Station"]
		if !hasStation {
			continue
		}

		// Get device name
		deviceProps, hasDevice := interfaces["net.connman.iwd.Device"]
		iface := ""
		if hasDevice {
			if name, ok := deviceProps["Name"]; ok {
				iface = name.Value().(string)
			}
		}

		// Get connection state
		stateVar, ok := stationProps["State"]
		if !ok {
			continue
		}
		state := stateVar.Value().(string)

		if state != "connected" {
			return wifi{iface: iface, connected: false}, nil
		}

		// Get connected network path
		networkPathVar, ok := stationProps["ConnectedNetwork"]
		if !ok {
			return wifi{iface: iface, connected: true, ssid: "unknown"}, nil
		}
		networkPath := networkPathVar.Value().(dbus.ObjectPath)

		// Get SSID from Network object
		networkObj := conn.Object("net.connman.iwd", networkPath)
		var ssid string
		err = networkObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"net.connman.iwd.Network", "Name").Store(&ssid)
		if err != nil {
			ssid = extractSSIDFromPath(string(path))
		}

		return wifi{iface: iface, ssid: ssid, connected: true}, nil
	}

	return wifi{}, fmt.Errorf("no iwd station found")
}

// getWifiNetworkManagerWithConn gets WiFi status using an existing connection
func getWifiNetworkManagerWithConn(conn *dbus.Conn) (wifi, error) {
	nm := conn.Object("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager")

	var devicePaths []dbus.ObjectPath
	err := nm.Call("org.freedesktop.DBus.Properties.Get", 0,
		"org.freedesktop.NetworkManager", "Devices").Store(&devicePaths)
	if err != nil {
		return wifi{}, fmt.Errorf("get devices: %w", err)
	}

	for _, devicePath := range devicePaths {
		deviceObj := conn.Object("org.freedesktop.NetworkManager", devicePath)

		// Check device type (2 = WiFi)
		var deviceType uint32
		err = deviceObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"org.freedesktop.NetworkManager.Device", "DeviceType").Store(&deviceType)
		if err != nil || deviceType != 2 {
			continue
		}

		// Get interface name
		var iface string
		err = deviceObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"org.freedesktop.NetworkManager.Device", "Interface").Store(&iface)
		if err != nil {
			iface = "wlan"
		}

		// Get device state (100 = activated/connected)
		var state uint32
		err = deviceObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"org.freedesktop.NetworkManager.Device", "State").Store(&state)
		if err != nil || state != 100 {
			return wifi{iface: iface, connected: false}, nil
		}

		// Get active access point
		var apPath dbus.ObjectPath
		err = deviceObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"org.freedesktop.NetworkManager.Device.Wireless", "ActiveAccessPoint").Store(&apPath)
		if err != nil || apPath == "/" {
			return wifi{iface: iface, connected: false}, nil
		}

		// Get SSID from access point
		apObj := conn.Object("org.freedesktop.NetworkManager", apPath)
		var ssidBytes []byte
		err = apObj.Call("org.freedesktop.DBus.Properties.Get", 0,
			"org.freedesktop.NetworkManager.AccessPoint", "Ssid").Store(&ssidBytes)
		if err != nil {
			return wifi{iface: iface, connected: true, ssid: "unknown"}, nil
		}

		return wifi{iface: iface, ssid: string(ssidBytes), connected: true}, nil
	}

	return wifi{}, fmt.Errorf("no NetworkManager WiFi device found")
}

func extractSSIDFromPath(path string) string {
	parts := strings.Split(path, "/")
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return "unknown"
}

// Legacy polling functions for compatibility
func pollWifi(args argsWifi) poller[wifi] {
	switch args.Backend {
	case backendIwd:
		return getWifiIwd
	case backendNetworkManager:
		return getWifiNetworkManager
	}
	return getWifiAuto
}

func getWifiAuto() (wifi, error) {
	result, err := getWifiIwd()
	if err == nil {
		return result, nil
	}
	return getWifiNetworkManager()
}

func getWifiIwd() (wifi, error) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return wifi{}, fmt.Errorf("system bus: %w", err)
	}
	defer conn.Close()
	return getWifiIwdWithConn(conn)
}

func getWifiNetworkManager() (wifi, error) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return wifi{}, fmt.Errorf("system bus: %w", err)
	}
	defer conn.Close()
	return getWifiNetworkManagerWithConn(conn)
}
