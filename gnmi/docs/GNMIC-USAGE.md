# gNMIc Usage Guide

Complete guide for using gNMIc to test and validate gNMI connectivity with Cisco IOS XE devices.

## Table of Contents
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Testing Scripts](#testing-scripts)
- [Common Commands](#common-commands)
- [YANG Path Discovery](#yang-path-discovery)
- [Troubleshooting](#troubleshooting)

## Installation

### macOS (Homebrew)
```bash
brew install gnmic
```

### Linux (Binary Download)
```bash
# Download latest release
bash -c "$(curl -sL https://get-gnmic.openconfig.net)"

# Or install to /usr/local/bin
sudo bash -c "$(curl -sL https://get-gnmic.openconfig.net)"
```

### Docker
```bash
docker pull ghcr.io/openconfig/gnmic:latest
```

### Verify Installation
```bash
gnmic version
```

## Basic Usage

### Connection Syntax

**Basic connection:**
```bash
gnmic -a DEVICE_IP:PORT \
  -u USERNAME \
  -p PASSWORD \
  --insecure \
  COMMAND
```

**With all common options:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  --encoding json_ietf \
  --timeout 30s \
  COMMAND
```

### Common Commands

| Command | Purpose |
|---------|---------|
| `capabilities` | Show device capabilities |
| `get` | Get current value |
| `subscribe` | Stream telemetry |
| `set` | Set configuration (use carefully!) |

## Testing Scripts

### 1. Test OpenConfig Components

**File:** `gnmic-test-oc-components.sh`

```bash
#!/bin/bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  subscribe \
  --path "openconfig:/components" \
  --stream-mode sample \
  --sample-interval 5s \
  --encoding json_ietf
```

**What it tests:**
- Platform components (fans, power supplies, chassis)
- Temperature sensors
- Component serial numbers and versions

**Expected output:**
```json
{
  "source": "10.85.134.65:9339",
  "subscription-name": "default-1730000000",
  "timestamp": 1730000000000000000,
  "time": "2025-11-04T12:00:00Z",
  "updates": [
    {
      "Path": "openconfig:/components/component[name=Switch1]",
      "values": {
        "component": {
          "name": "Switch1",
          "state": {
            "type": "CHASSIS",
            "description": "C9300X-48HX"
          }
        }
      }
    }
  ]
}
```

### 2. Test OpenConfig System

**File:** `gnmic-test-oc-system.sh`

```bash
#!/bin/bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  subscribe \
  --path "openconfig:/system" \
  --stream-mode sample \
  --sample-interval 10s \
  --encoding json_ietf
```

**What it tests:**
- System configuration (AAA, users, etc.)
- Hostname and domain
- DNS and NTP settings

### 3. Comprehensive OpenConfig Test

**File:** `test-all-openconfig-paths.sh`

```bash
#!/bin/bash

echo "=== Testing OpenConfig Interfaces ==="
gnmic -a 10.85.134.65:9339 -u admin -p Cisco123 --insecure \
  subscribe --path "openconfig:/interfaces/interface/state/counters" \
  --stream-mode sample --sample-interval 5s --count 2

echo ""
echo "=== Testing OpenConfig Platform ==="
gnmic -a 10.85.134.65:9339 -u admin -p Cisco123 --insecure \
  subscribe --path "openconfig:/components" \
  --stream-mode sample --sample-interval 5s --count 2

echo ""
echo "=== Testing OpenConfig System ==="
gnmic -a 10.85.134.65:9339 -u admin -p Cisco123 --insecure \
  subscribe --path "openconfig:/system" \
  --stream-mode sample --sample-interval 5s --count 2
```

## Common Commands

### 1. Capabilities

**Show what the device supports:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  capabilities
```

**Expected output includes:**
- Supported encodings: `JSON_IETF`, `PROTO`
- YANG models available
- gNMI version

### 2. Get (One-time Read)

**Get interface counters:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  get \
  --path "openconfig:/interfaces/interface/state/counters" \
  --encoding json_ietf
```

**Get CPU usage:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  get \
  --path "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization" \
  --encoding json_ietf
```

### 3. Subscribe (Streaming)

**Stream interface counters:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  subscribe \
  --path "openconfig:/interfaces/interface/state/counters" \
  --stream-mode sample \
  --sample-interval 10s
```

**Subscribe with count (limit samples):**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  subscribe \
  --path "openconfig:/components" \
  --stream-mode sample \
  --sample-interval 10s \
  --count 5  # Stop after 5 samples
```

**Subscribe to multiple paths:**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  subscribe \
  --path "openconfig:/interfaces/interface/state/counters" \
  --path "openconfig:/components" \
  --stream-mode sample \
  --sample-interval 10s
```

### 4. Output Formats

**JSON output:**
```bash
gnmic ... subscribe --format json
```

**Protobuf output:**
```bash
gnmic ... subscribe --format protobuf
```

**Flat format (easier to read):**
```bash
gnmic ... subscribe --format flat
```

**Write to file:**
```bash
gnmic ... subscribe > output.json
```

## YANG Path Discovery

### Find Available Paths

**Method 1: Capabilities**
```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p Cisco123 \
  --insecure \
  capabilities | grep -i "name:"
```

**Method 2: Get Root**
```bash
# OpenConfig root
gnmic ... get --path "openconfig:/"

# Cisco Native root
gnmic ... get --path "/"
```

### Common OpenConfig Paths

```bash
# Interfaces
openconfig:/interfaces/interface
openconfig:/interfaces/interface/state/counters
openconfig:/interfaces/interface/config

# Platform
openconfig:/components
openconfig:/components/component[name=*]/state

# System
openconfig:/system
openconfig:/system/aaa
openconfig:/system/config

# Network Instances
openconfig:/network-instances/network-instance
```

### Common Cisco Native Paths

```bash
# CPU Usage
/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization

# Memory
/memory-ios-xe-oper:memory-statistics/memory-statistic

# Environment
/environment-ios-xe-oper:environment-sensors

# LLDP
/lldp-ios-xe-oper:lldp-entries

# CDP
/cdp-ios-xe-oper:cdp-neighbor-details

# ARP
/arp-ios-xe-oper:arp-data/arp-vrf

# PoE
/poe-oper-data:poe-oper-data
```

## Stream Modes

### Sample Mode (Periodic)

**Use for:** Counters, statistics, regular polling

```bash
gnmic ... subscribe \
  --stream-mode sample \
  --sample-interval 10s
```

### On-Change Mode (Event-driven)

**Use for:** Configuration changes, state changes

```bash
gnmic ... subscribe \
  --stream-mode on_change
```

### Target-Defined Mode

**Use for:** Let device determine frequency

```bash
gnmic ... subscribe \
  --stream-mode target_defined
```

## Advanced Usage

### Multiple Devices

**Using config file (gnmic.yaml):**
```yaml
targets:
  switch1:
    address: 10.85.134.65:9339
    username: admin
    password: password
    insecure: true

  switch2:
    address: 10.85.134.66:9339
    username: admin
    password: password
    insecure: true

subscriptions:
  interfaces:
    paths:
      - openconfig:/interfaces/interface/state/counters
    stream-mode: sample
    sample-interval: 10s
```

**Run with config:**
```bash
gnmic --config gnmic.yaml subscribe --name interfaces
```

### Output to File

**JSON file:**
```bash
gnmic ... subscribe > telemetry.json
```

**JSON Lines (one JSON per line):**
```bash
gnmic ... subscribe --format json-lines > telemetry.jsonl
```

### Filtering Output

**Use jq for JSON filtering:**
```bash
gnmic ... subscribe | jq '.updates[].values'
```

**Filter specific interfaces:**
```bash
gnmic ... subscribe | jq '.updates[] | select(.Path | contains("GigabitEthernet1/0/1"))'
```

## Troubleshooting

### Connection Issues

**Error: connection refused**
```bash
# Check device is reachable
ping 10.85.134.65

# Check port is open
nc -zv 10.85.134.65 9339

# Verify gNMI is enabled on device
```

**Error: authentication failed**
```bash
# Verify credentials
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p WRONG_PASSWORD \
  --insecure \
  capabilities  # This will fail with wrong creds
```

### Certificate Issues

**Error: x509 certificate error**
```bash
# Use --insecure flag for self-signed certs
gnmic ... --insecure capabilities

# Or specify CA certificate
gnmic ... --tls-ca /path/to/ca.pem capabilities
```

### Path Not Found

**Error: path not found**
```bash
# Check if path exists
gnmic ... get --path "openconfig:/"

# Try without origin prefix
gnmic ... get --path "/interfaces"

# Verify YANG model is supported
gnmic ... capabilities | grep -i "interfaces"
```

### Empty Response

**Issue: Subscribe returns no data**

**Checks:**
1. Verify path syntax
2. Try `get` instead of `subscribe` first
3. Check device supports the YANG model
4. Verify stream mode is appropriate

```bash
# Debug with verbose output
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p password \
  --insecure \
  --debug \
  subscribe --path "openconfig:/components"
```

## Useful Workflows

### Quick Device Validation

```bash
#!/bin/bash
# validate-device.sh

echo "Testing gNMI connectivity to $1"

# Test 1: Capabilities
echo "=== Capabilities ==="
gnmic -a $1:9339 -u admin -p password --insecure capabilities

# Test 2: Get interfaces
echo "=== Interface Test ==="
gnmic -a $1:9339 -u admin -p password --insecure \
  get --path "openconfig:/interfaces/interface[name=*]/state/name"

# Test 3: Subscribe CPU
echo "=== CPU Usage Test ==="
gnmic -a $1:9339 -u admin -p password --insecure \
  subscribe --path "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization" \
  --stream-mode sample --sample-interval 5s --count 2

echo "=== Tests Complete ==="
```

**Usage:**
```bash
./validate-device.sh 10.85.134.65
```

### Path Discovery

```bash
#!/bin/bash
# discover-paths.sh

DEVICE=$1

echo "Discovering paths on $DEVICE..."

# Get all OpenConfig paths
echo "=== OpenConfig Paths ==="
gnmic -a $DEVICE:9339 -u admin -p password --insecure \
  get --path "openconfig:/" | jq -r '.. | objects | keys[]' | sort -u

echo ""
echo "=== Cisco Native Paths ==="
gnmic -a $DEVICE:9339 -u admin -p password --insecure \
  capabilities | grep "name:" | grep -v "openconfig"
```

### Benchmark Collection

```bash
#!/bin/bash
# benchmark.sh

echo "Benchmarking gNMI subscription..."

time gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p password \
  --insecure \
  subscribe \
  --path "openconfig:/interfaces/interface/state/counters" \
  --stream-mode sample \
  --sample-interval 1s \
  --count 60 > /dev/null

echo "Collected 60 samples"
```

## Best Practices

1. **Start with capabilities**: Always check device capabilities first
2. **Test with get**: Use `get` before `subscribe` to verify paths
3. **Limit samples**: Use `--count` during testing to avoid infinite streams
4. **Use appropriate intervals**: Don't poll too frequently
5. **Filter output**: Use `jq` to parse JSON efficiently
6. **Save working commands**: Document successful commands for reuse
7. **Use config files**: For complex multi-device setups
8. **Handle errors**: Check exit codes in scripts

## Common Patterns

### Test Before Telegraf

Always validate paths with gNMIc before using in Telegraf:

```bash
# 1. Test the path works
gnmic ... get --path "YOUR_PATH"

# 2. Test subscription works
gnmic ... subscribe --path "YOUR_PATH" --count 2

# 3. Add to Telegraf config
# Now add the working path to telegraf config
```

### Quick Data Sample

Get a quick sample to see data format:

```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p password \
  --insecure \
  subscribe \
  --path "openconfig:/components" \
  --stream-mode sample \
  --sample-interval 5s \
  --count 1 \
  | jq '.'
```

### Monitor Specific Interface

```bash
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p password \
  --insecure \
  subscribe \
  --path "openconfig:/interfaces/interface[name=GigabitEthernet1/0/1]/state/counters" \
  --stream-mode sample \
  --sample-interval 5s
```

## Additional Resources

- [gNMIc Documentation](https://gnmic.openconfig.net/)
- [gNMI Protocol Specification](https://github.com/openconfig/reference/blob/master/rpc/gnmi/gnmi-specification.md)
- [OpenConfig Models](https://github.com/openconfig/public)
- [Cisco YANG Models](https://github.com/YangModels/yang/tree/main/vendor/cisco)

---

**Last Updated**: November 2025
**gNMIc Version**: Latest
