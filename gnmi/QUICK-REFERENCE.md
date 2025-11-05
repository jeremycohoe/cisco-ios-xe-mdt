# Quick Reference Guide

Fast reference for common gNMI operations with Cisco IOS XE.

## Quick Start

### Test Device Connectivity
```bash
gnmic -a 10.85.134.65:9339 -u admin -p password --insecure capabilities
```

### Run Basic Telegraf Collection
```bash
cd gnmi/telegraf
telegraf --config telegraf-gnmi-basic.conf
```

### View Collected Data
```bash
tail -f /tmp/telegraf-gnmi-output.log
```

---

## Common Telegraf Commands

```bash
# Test configuration
telegraf --config CONFIG_FILE --test

# Test with debug output
telegraf --config CONFIG_FILE --test --debug

# Run in foreground
telegraf --config CONFIG_FILE

# Run for 30 seconds then stop
timeout 30 telegraf --config CONFIG_FILE

# Check file output
ls -lh /tmp/*.log
wc -l /tmp/telegraf-gnmi-output.log
```

---

## Common gNMIc Commands

```bash
# Device capabilities
gnmic -a DEVICE:9339 -u USER -p PASS --insecure capabilities

# Get data once
gnmic -a DEVICE:9339 -u USER -p PASS --insecure \
  get --path "openconfig:/interfaces"

# Subscribe to stream
gnmic -a DEVICE:9339 -u USER -p PASS --insecure \
  subscribe --path "openconfig:/components" \
  --stream-mode sample --sample-interval 10s

# Limit to N samples
gnmic -a DEVICE:9339 -u USER -p PASS --insecure \
  subscribe --path "PATH" --count 5
```

---

## Configuration Snippets

### Minimal Telegraf Config
```toml
[agent]
  interval = "10s"

[[outputs.file]]
  files = ["/tmp/output.log"]

[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "password"
  encoding = "json_ietf"
  enable_tls = true
  insecure_skip_verify = true

  [[inputs.gnmi.subscription]]
    name = "interfaces"
    origin = "openconfig"
    path = "/interfaces/interface/state/counters"
    subscription_mode = "sample"
    sample_interval = "10s"
```

### Add Multiple Subscriptions
```toml
[[inputs.gnmi]]
  # Connection settings...

  [[inputs.gnmi.subscription]]
    name = "subscription1"
    # ...

  [[inputs.gnmi.subscription]]
    name = "subscription2"
    # ...

  [inputs.gnmi.tags]
    source = "device_ip"
```

---

## Common Paths

### OpenConfig
```toml
# Interfaces
path = "/interfaces/interface/state/counters"

# Platform
path = "/components"

# System
path = "/system"
```

### Cisco Native
```toml
# CPU
origin = "legacy"
path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"

# Memory
origin = "legacy"
path = "/memory-ios-xe-oper:memory-statistics/memory-statistic"

# LLDP
origin = "legacy"
path = "/lldp-ios-xe-oper:lldp-entries"
```

---

## Troubleshooting Quick Checks

```bash
# 1. Can reach device?
ping 10.85.134.65

# 2. Port open?
nc -zv 10.85.134.65 9339

# 3. Test with gNMIc
gnmic -a 10.85.134.65:9339 -u admin -p password --insecure capabilities

# 4. Test Telegraf config
telegraf --config CONFIG --test

# 5. Check output
ls -lh /tmp/*.log

# 6. Count [[inputs.gnmi]] sections (should be 1!)
grep -c "^\[\[inputs.gnmi\]\]" CONFIG
```

---

## Device Configuration

```cisco
! Enable gNMI
gnmi-yang
gnmi-yang server
gnmi-yang port 9339

! Create user
username admin privilege 15 secret MyPassword

! AAA (if using)
aaa new-model
aaa authentication login default local
aaa authorization exec default local
```

---

## File Locations

| File | Location |
|------|----------|
| Telegraf configs | `gnmi/telegraf/` |
| gNMIc scripts | `gnmi/gnmic/` |
| Documentation | `gnmi/docs/` |
| Output logs | `/tmp/` |

---

## Common Issues & Fixes

| Issue | Quick Fix |
|-------|-----------|
| Connection refused | Enable gNMI on device |
| Auth failed | Check username/password |
| Empty logs | Check for multiple `[[inputs.gnmi]]` sections |
| Path not found | Test with gNMIc first |
| High CPU | Reduce sample frequency |

---

## Getting Started Workflow

1. **Test connectivity**: `gnmic ... capabilities`
2. **Test path**: `gnmic ... get --path "PATH"`
3. **Create config**: Start with basic template
4. **Test config**: `telegraf --config ... --test`
5. **Run collection**: `telegraf --config ...`
6. **Verify output**: `ls -lh /tmp/*.log`
7. **Expand**: Add more subscriptions incrementally

---

**For full details, see documentation in `gnmi/docs/`**
