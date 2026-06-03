# MQTT Communication Protocol

This document outlines the MQTT topics and JSON payload structures used for communication between the Flutter Application and the Smart Relay Boards.

## Base Topic Structure
All topics follow the pattern: `smart_relay/{serial}/{sub_topic}`

---

## 1. Handshake & Onboarding
Used when adding a new board to the application.

### Handshake Request (App → Board)
- **Topic:** `smart_relay/handshake/request`
- **Payload:**
```json
{
  "serial": "DEVICE_SERIAL_NUMBER"
}
```

### Handshake Response (Board → App)
- **Topic:** `smart_relay/handshake/response`
- **Payload:**
```json
{
  "serial": "DEVICE_SERIAL_NUMBER",
  "success": true,
  "relays": 8
}
```
*Note: `relays` indicates the number of relay channels on the hardware (e.g., 4, 8, 20).*

---

## 2. Status & State
Used to sync the UI with the physical state of the relays.

### Status Request (App → Board)
- **Topic:** `smart_relay/{serial}/status_request`
- **Payload:**
```json
{
  "serial": "DEVICE_SERIAL_NUMBER"
}
```

### State Update (Board → App)
- **Topic:** `smart_relay/{serial}/state`
- **Payload:**
```json
{
  "relays": [true, false, true, false, ...]
}
```
*Note: The list length corresponds to the number of relays.*

---

## 3. Control Commands
Used to toggle relays.

### Relay Command (App → Board)
- **Topic:** `smart_relay/{serial}/command`
- **Payload:**
```json
{
  "serial": "DEVICE_SERIAL_NUMBER",
  "relays": [true, true, false, ...]
}
```
*Note: The board expects the full state of all relays in each command.*

---

## 4. Timing & Monitoring
Used for real-time monitoring of relay durations/timers.

### Timing Request (App → Board)
- **Topic:** `smart_relay/{serial}/timing_request`
- **Payload:**
```json
{
  "serial": "DEVICE_SERIAL_NUMBER",
  "command": "start" 
}
```
*Options for `command`: `"start"`, `"stop"`, `"reset"`.*

### Timing State (Board → App)
- **Topic:** `smart_relay/{serial}/timing_state`
- **Payload:**
```json
{
  "times": [120, 0, 45, ...]
}
```
*Note: `times` is a list of integers (e.g., seconds or milliseconds) for each relay.*
