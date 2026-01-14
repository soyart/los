package main

import (
	"fmt"
	"strings"

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

// watchWifi returns a watcher that listens for WiFi state changes via D-Bus signals.
// This is a pure signal listener with no polling - polling is handled separately by poll().
func watchWifi(args argsWifi) watcher[wifi] {
	switch args.Backend {
	case backendIwd:
		return watchWifiIwd
	case backendNetworkManager:
		return watchWifiNetworkManager
	}
	return watchWifiAuto
}

// watchWifiAuto tries iwd first, falls back to NetworkManager
func watchWifiAuto(ch chan<- result[wifi]) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		ch <- result[wifi]{err: fmt.Errorf("system bus: %w", err)}
		return
	}
	// Try iwd first
	if err := subscribeIwd(conn); err == nil {
		watchWifiIwdWithConn(conn, ch)
		return
	}
	// Fall back to NetworkManager
	if err := subscribeNetworkManager(conn); err == nil {
		watchWifiNetworkManagerWithConn(conn, ch)
		return
	}
	ch <- result[wifi]{err: fmt.Errorf("no wifi backend available")}
}

// watchWifiIwd is a pure D-Bus signal watcher for iwd (no polling)
func watchWifiIwd(ch chan<- result[wifi]) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		ch <- result[wifi]{err: fmt.Errorf("system bus: %w", err)}
		return
	}
	if err := subscribeIwd(conn); err != nil {
		conn.Close()
		ch <- result[wifi]{err: err}
		return
	}
	watchWifiIwdWithConn(conn, ch)
}

func subscribeIwd(conn *dbus.Conn) error {
	return conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchPathNamespace("/net/connman/iwd"),
	)
}

func watchWifiIwdWithConn(conn *dbus.Conn, ch chan<- result[wifi]) {
	signals := make(chan *dbus.Signal, 10)
	conn.Signal(signals)

	// Send initial state
	w, err := getWifiIwdWithConn(conn)
	ch <- result[wifi]{value: w, err: err}

	// Pure signal handling - no ticker
	for sig := range signals {
		if len(sig.Body) < 1 {
			continue
		}
		ifaceName, ok := sig.Body[0].(string)
		if ok && (ifaceName == "net.connman.iwd.Station" ||
			ifaceName == "net.connman.iwd.Network") {
			w, err := getWifiIwdWithConn(conn)
			ch <- result[wifi]{value: w, err: err}
		}
	}
}

// watchWifiNetworkManager is a pure D-Bus signal watcher for NetworkManager (no polling)
func watchWifiNetworkManager(ch chan<- result[wifi]) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		ch <- result[wifi]{err: fmt.Errorf("system bus: %w", err)}
		return
	}
	if err := subscribeNetworkManager(conn); err != nil {
		conn.Close()
		ch <- result[wifi]{err: err}
		return
	}
	watchWifiNetworkManagerWithConn(conn, ch)
}

func subscribeNetworkManager(conn *dbus.Conn) error {
	return conn.AddMatchSignal(
		dbus.WithMatchInterface("org.freedesktop.DBus.Properties"),
		dbus.WithMatchMember("PropertiesChanged"),
		dbus.WithMatchPathNamespace("/org/freedesktop/NetworkManager"),
	)
}

func watchWifiNetworkManagerWithConn(conn *dbus.Conn, ch chan<- result[wifi]) {
	signals := make(chan *dbus.Signal, 10)
	conn.Signal(signals)

	// Send initial state
	w, err := getWifiNetworkManagerWithConn(conn)
	ch <- result[wifi]{value: w, err: err}

	// Pure signal handling - no ticker
	for sig := range signals {
		if len(sig.Body) < 1 {
			continue
		}
		ifaceName, ok := sig.Body[0].(string)
		if ok && (strings.Contains(ifaceName, "Device") ||
			strings.Contains(ifaceName, "AccessPoint") ||
			strings.Contains(ifaceName, "Connection")) {
			w, err := getWifiNetworkManagerWithConn(conn)
			ch <- result[wifi]{value: w, err: err}
		}
	}
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
