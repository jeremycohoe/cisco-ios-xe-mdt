# Telegraf gNMI Setup Guide

Complete guide for setting up Telegraf to collect Model-Driven Telemetry from Cisco IOS XE devices.

## Table of Contents
- [Installation](#installation)
- [Basic Configuration](#basic-configuration)
- [Advanced Configuration](#advanced-configuration)
- [Configuration Patterns](#configuration-patterns)
- [Output Options](#output-options)
- [Running Telegraf](#running-telegraf)
- [Validation](#validation)

## Installation

### macOS (Homebrew)
```bash
brew install telegraf
```

### Linux (Ubuntu/Debian)
```bash
curl -s https://repos.influxdata.com/influxdata-archive_compat.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt update
sudo apt install telegraf
```

### Linux (RHEL/CentOS)
```bash
cat <<EOF | sudo tee /etc/yum.repos.d/influxdata.repo
[influxdata]
name = InfluxData Repository
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF

sudo yum install telegraf
```

### Verify Installation
```bash
telegraf --version
# Expected: Telegraf 1.30+ (tested with 1.36.3)
```

## IOS XE Device Configuration

Before configuring Telegraf, ensure gNMI is enabled on your Cisco IOS XE device:

```cisco
! Enable gNMI server with secure authentication
gnxi
gnxi secure-allow-self-signed-trustpoint
gnxi secure-password-auth
gnxi secure-server
gnxi server
```

**Optional for Lab Environments Only** (not for production):
```cisco
service internal
gnxi secure-init
```

**Verification**:
```cisco
show gnxi state detail
```

Expected output should show:
- **State**: Enabled
- **Server**: Running
- **Port**: 9339 (default)

## Basic Configuration

### Minimum Required Settings

```toml
# Global Agent Configuration
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0s"
  debug = false
  quiet = false
  hostname = ""
  omit_hostname = false

# Output Plugin (choose one)
[[outputs.file]]
  files = ["/tmp/telegraf-gnmi-output.log"]
  data_format = "influx"

# Input Plugin
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "Cisco123"

  encoding = "json_ietf"
  redial = "20s"
  enable_tls = true
  insecure_skip_verify = true

  [[inputs.gnmi.subscription]]
    name = "oc_interface_counters"
    origin = "openconfig"
    path = "/interfaces/interface/state/counters"
    subscription_mode = "sample"
    sample_interval = "10s"
```

### Device Settings to Modify

**1. Connection Details**
```toml
addresses = ["YOUR_DEVICE_IP:9339"]  # Change to your device
username = "YOUR_USERNAME"            # Change to your username
password = "YOUR_PASSWORD"            # Change to your password
```

**2. Tags (Optional but Recommended)**
```toml
[inputs.gnmi.tags]
  source = "10.85.134.65"      # Device IP
  device_type = "c9300"        # Device model
  site = "lab"                 # Your site name
  location = "datacenter-1"    # Physical location
  role = "access-switch"       # Device role
```

## Advanced Configuration

### Multiple Subscriptions Pattern

**✅ CORRECT - Single `[[inputs.gnmi]]` Section**

```toml
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "password"
  encoding = "json_ietf"
  enable_tls = true
  insecure_skip_verify = true

  # OpenConfig Subscriptions
  [[inputs.gnmi.subscription]]
    name = "oc_interface_counters"
    origin = "openconfig"
    path = "/interfaces/interface/state/counters"
    subscription_mode = "sample"
    sample_interval = "10s"

  [[inputs.gnmi.subscription]]
    name = "oc_platform"
    origin = "openconfig"
    path = "/components"
    subscription_mode = "sample"
    sample_interval = "30s"

  # Cisco Native Subscriptions
  [[inputs.gnmi.subscription]]
    name = "cpu_usage"
    origin = "legacy"
    path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"
    subscription_mode = "sample"
    sample_interval = "10s"

  [inputs.gnmi.tags]
    source = "10.85.134.65"
    device_type = "c9300"
```

**❌ INCORRECT - Multiple `[[inputs.gnmi]]` Sections**

```toml
# DON'T DO THIS - Causes subscription failures!
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  [[inputs.gnmi.subscription]]
    name = "oc_platform"

[[inputs.gnmi]]  # WRONG - Second section
  addresses = ["10.85.134.65:9339"]
  [[inputs.gnmi.subscription]]
    name = "cpu_usage"
```

### Subscription Types

**1. OpenConfig (Standard Models)**
```toml
[[inputs.gnmi.subscription]]
  name = "oc_interfaces"
  origin = "openconfig"
  path = "/interfaces/interface/state/counters"
  subscription_mode = "sample"
  sample_interval = "10s"
```

**2. Cisco Native (Device-Specific)**
```toml
[[inputs.gnmi.subscription]]
  name = "cpu_usage"
  origin = "legacy"  # Note: use "legacy" not "Cisco-IOS-XE-process-cpu-oper"
  path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"
  subscription_mode = "sample"
  sample_interval = "10s"
```

### Subscription Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `sample` | Periodic sampling at intervals | Counters, statistics |
| `on_change` | Only when value changes | Configuration, state |
| `target_defined` | Device determines frequency | Let device optimize |

## Output Options

### 1. File Output (Development/Testing)

**Single File:**
```toml
[[outputs.file]]
  files = ["/tmp/telegraf-gnmi-output.log"]
  data_format = "influx"
```

**Multiple Files (per subscription):**
```toml
[[outputs.file]]
  files = ["/tmp/$MEASUREMENT.log"]
  data_format = "influx"
```

### 2. InfluxDB Output (Production)

```toml
[[outputs.influxdb_v2]]
  urls = ["http://localhost:8086"]
  token = "your-influxdb-token"
  organization = "your-org"
  bucket = "telegraf"
```

### 3. Prometheus Output

```toml
[[outputs.prometheus_client]]
  listen = ":9273"
  path = "/metrics"
```

### 4. Multiple Outputs

```toml
# Write to both file and InfluxDB
[[outputs.file]]
  files = ["/var/log/telegraf/gnmi.log"]
  data_format = "influx"

[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  token = "$INFLUX_TOKEN"
  organization = "myorg"
  bucket = "network_metrics"
```

## Running Telegraf

### Test Configuration (Dry Run)

```bash
# Test config syntax and connection
telegraf --config telegraf-gnmi-basic.conf --test

# Test and show what would be collected (verbose)
telegraf --config telegraf-gnmi-basic.conf --test --debug
```

### Run Once (Foreground)

```bash
# Run in foreground (Ctrl+C to stop)
telegraf --config telegraf-gnmi-basic.conf

# Run with debug output
telegraf --config telegraf-gnmi-basic.conf --debug
```

### Run as Service (Background)

**macOS (LaunchD):**
```bash
brew services start telegraf
brew services stop telegraf
brew services restart telegraf
```

**Linux (systemd):**
```bash
sudo systemctl start telegraf
sudo systemctl stop telegraf
sudo systemctl restart telegraf
sudo systemctl status telegraf

# View logs
sudo journalctl -u telegraf -f
```

### Run with Custom Config

```bash
# Specify config file
telegraf --config /path/to/custom-config.conf

# Use config directory (loads all .conf files)
telegraf --config-directory /etc/telegraf/telegraf.d/
```

## Validation

### Step 1: Syntax Check

```bash
telegraf --config telegraf-gnmi-basic.conf --test
```

**Expected output:**
```
> oc_interface_counters,device_type=c9300,host=...,name=GigabitEthernet1/0/1...
> cpu_usage,device_type=c9300,host=...,path=process-cpu-ios-xe-oper:cpu-usage...
```

### Step 2: Check Connection

```bash
# Run for 30 seconds
timeout 30 telegraf --config telegraf-gnmi-basic.conf --debug 2>&1 | grep -i "error\|success\|connected"
```

**Look for:**
- ✅ `Successfully subscribed to...`
- ❌ `connection refused` - Check device IP/port
- ❌ `authentication failed` - Check credentials

### Step 3: Verify Data Collection

```bash
# Run for 30 seconds
telegraf --config telegraf-gnmi-basic.conf &
TELEGRAF_PID=$!
sleep 30
kill $TELEGRAF_PID

# Check output file
ls -lh /tmp/telegraf-gnmi-output.log
wc -l /tmp/telegraf-gnmi-output.log
```

**Expected:**
- File size > 0 bytes
- Multiple lines of data
- Recent timestamp

### Step 4: Inspect Data Format

```bash
# View first 5 lines
head -5 /tmp/telegraf-gnmi-output.log

# Check for specific subscription
grep "oc_platform" /tmp/telegraf-gnmi-output.log | head -2

# Count samples per subscription
grep -o '^[a-z_]*,' /tmp/telegraf-gnmi-output.log | sort | uniq -c
```

## Performance Tuning

### Adjust Collection Intervals

```toml
[agent]
  interval = "10s"          # Default collection interval
  flush_interval = "10s"    # How often to flush to output

[[inputs.gnmi.subscription]]
  sample_interval = "10s"   # Per-subscription override
```

**Recommendations:**
- Interface counters: 10s (high-frequency)
- CPU/Memory: 10-30s (medium-frequency)
- Platform/System: 60-300s (low-frequency)

### Buffer Settings

```toml
[agent]
  metric_batch_size = 1000      # Max metrics per batch
  metric_buffer_limit = 10000   # Max metrics to buffer
```

**Guidelines:**
- Small deployments: defaults are fine
- Large deployments: increase buffer limits
- High-frequency data: increase batch size

### Memory Usage

Monitor Telegraf memory:
```bash
# Linux
ps aux | grep telegraf

# macOS
top -pid $(pgrep telegraf)
```

Reduce memory if needed:
- Decrease collection intervals
- Reduce subscription count
- Lower buffer limits

## Troubleshooting

### Issue: No Data Collected

**Check 1:** Verify gNMI is enabled on device
```cisco
show running-config | include gnmi
```

**Check 2:** Test with gNMIc first
```bash
gnmic -a DEVICE_IP:9339 -u admin -p password --insecure \
  subscribe --path "openconfig:/interfaces"
```

**Check 3:** Check Telegraf logs
```bash
telegraf --config telegraf-gnmi-basic.conf --debug 2>&1 | less
```

### Issue: Authentication Errors

```toml
# Ensure credentials are correct
username = "admin"
password = "correct-password"

# Verify TLS settings
enable_tls = true
insecure_skip_verify = true  # For self-signed certs
```

### Issue: Some Subscriptions Return 0 Bytes

**Most Common Cause:** Multiple `[[inputs.gnmi]]` sections

**Solution:** Consolidate to single section:
```toml
# ONE section only
[[inputs.gnmi]]
  # All connection settings here

  [[inputs.gnmi.subscription]]
    # First subscription

  [[inputs.gnmi.subscription]]
    # Second subscription

  # More subscriptions...
```

### Issue: High CPU Usage

**Causes:**
- Too many subscriptions
- Too frequent sampling
- Large data volume

**Solutions:**
```toml
# Increase intervals
sample_interval = "30s"  # Was 10s

# Reduce subscriptions
# Comment out non-essential subscriptions

# Batch processing
[agent]
  metric_batch_size = 5000  # Increase from 1000
```

## Best Practices

1. **Start Small**: Begin with basic config, add subscriptions gradually
2. **Test First**: Always use `--test` before production deployment
3. **Use Tags**: Tag data appropriately for filtering and grouping
4. **Monitor Performance**: Watch Telegraf CPU/memory usage
5. **Single Input Section**: Always use ONE `[[inputs.gnmi]]` section
6. **Version Control**: Keep configs in Git for tracking changes
7. **Document Custom Paths**: Comment non-obvious YANG paths
8. **Regular Validation**: Periodically verify data collection

## Example Workflows

### Development Workflow
```bash
# 1. Test syntax
telegraf --config new-config.conf --test

# 2. Run for 30s and verify
timeout 30 telegraf --config new-config.conf
ls -lh /tmp/*.log

# 3. Check data format
head -10 /tmp/oc_interface_counters.log

# 4. Deploy to production
sudo cp new-config.conf /etc/telegraf/telegraf.d/
sudo systemctl restart telegraf
```

### Production Deployment
```bash
# 1. Validate config
telegraf --config production.conf --test

# 2. Backup existing config
sudo cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.backup

# 3. Deploy new config
sudo cp production.conf /etc/telegraf/telegraf.conf

# 4. Restart service
sudo systemctl restart telegraf

# 5. Monitor logs
sudo journalctl -u telegraf -f

# 6. Verify metrics in output
# (Check InfluxDB, Prometheus, etc.)
```

## Additional Resources

- [Telegraf gNMI Plugin Documentation](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/gnmi)
- [InfluxData Documentation](https://docs.influxdata.com/telegraf/)
- [Cisco MDT Configuration Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/1712/b_1712_programmability_cg/model_driven_telemetry.html)

---

**Last Updated**: November 2025
**Telegraf Version**: 1.36.3
