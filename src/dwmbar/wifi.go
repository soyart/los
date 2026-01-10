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
	Cache   bool   `json:"cache"`
}

func (w wifi) String() string {
	if !w.connected {
		return "wifi(disconnected)"
	}
	return fmt.Sprintf("wifi(%s): %s", w.iface, w.ssid)
}

func pollWifi(args argsWifi) poller[wifi] {
	switch args.Backend {
	case backendIwd:
		return getWifiIwd
	case backendNetworkManager:
		return getWifiNetworkManager
	}
	// auto: try iwd first, fall back to NetworkManager
	return getWifiAuto
}

func getWifiAuto() (wifi, error) {
	result, err := getWifiIwd()
	if err == nil {
		return result, nil
	}
	return getWifiNetworkManager()
}

// getWifiIwd gets WiFi status via iwd D-Bus (session bus)
// Service: net.connman.iwd
// Interface: net.connman.iwd.Station
func getWifiIwd() (wifi, error) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return wifi{}, fmt.Errorf("system bus: %w", err)
	}
	defer conn.Close()

	// Get managed objects to find station interface
	iwd := conn.Object("net.connman.iwd", "/")
	var objects map[dbus.ObjectPath]map[string]map[string]dbus.Variant
	err = iwd.Call("org.freedesktop.DBus.ObjectManager.GetManagedObjects", 0).Store(&objects)
	if err != nil {
		return wifi{}, fmt.Errorf("get managed objects: %w", err)
	}

	// Find first Station object
	for path, interfaces := range objects {
		stationProps, hasStation := interfaces["net.connman.iwd.Station"]
		if !hasStation {
			continue
		}

		// Get device name from Device interface
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
			// Try to extract from path as fallback
			ssid = extractSSIDFromPath(string(path))
		}

		return wifi{
			iface:     iface,
			ssid:      ssid,
			connected: true,
		}, nil
	}

	return wifi{}, fmt.Errorf("no iwd station found")
}

// getWifiNetworkManager gets WiFi status via NetworkManager D-Bus (system bus)
// Service: org.freedesktop.NetworkManager
func getWifiNetworkManager() (wifi, error) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return wifi{}, fmt.Errorf("system bus: %w", err)
	}
	defer conn.Close()

	nm := conn.Object("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager")

	// Get all devices
	var devicePaths []dbus.ObjectPath
	err = nm.Call("org.freedesktop.DBus.Properties.Get", 0,
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

		return wifi{
			iface:     iface,
			ssid:      string(ssidBytes),
			connected: true,
		}, nil
	}

	return wifi{}, fmt.Errorf("no NetworkManager WiFi device found")
}

func extractSSIDFromPath(path string) string {
	// Path format: /net/connman/iwd/0/4/SSID_hex
	parts := strings.Split(path, "/")
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return "unknown"
}
