# Troubleshooting Guide

Common issues and solutions when working with gNMI on Cisco IOS XE devices.

## Table of Contents
- [Connection Issues](#connection-issues)
- [Authentication Problems](#authentication-problems)
- [Configuration Issues](#configuration-issues)
- [Data Collection Problems](#data-collection-problems)
- [Performance Issues](#performance-issues)
- [Device-Specific Issues](#device-specific-issues)

---

## Connection Issues

### Issue: Connection Refused

**Symptoms:**
```
Error: connection refused
dial tcp 10.85.134.65:9339: connect: connection refused
```

**Causes & Solutions:**

**1. gNMI not enabled on device**
```cisco
! Check if gNMI is configured
show running-config | include gnmi

! Enable gNMI if missing
configure terminal
  gnmi-yang
  gnmi-yang server
  gnmi-yang port 9339
  exit
```

**2. Wrong IP address or port**
```bash
# Verify device IP
ping 10.85.134.65

# Check if port is open
nc -zv 10.85.134.65 9339
telnet 10.85.134.65 9339
```

**3. Firewall or ACL blocking**
```cisco
! Check ACLs
show ip access-lists

! Add ACL if needed
ip access-list extended GNMI-ACCESS
  permit tcp host YOUR_TELEGRAF_IP any eq 9339
```

**4. VRF routing issue**
```cisco
! Check if gNMI is in correct VRF
show gnmi-yang state detail

! Configure VRF if needed
gnmi-yang server vrf Mgmt-vrf
```

### Issue: Connection Timeout

**Symptoms:**
```
Error: context deadline exceeded
```

**Solutions:**

```bash
# Increase timeout in Telegraf
[[inputs.gnmi]]
  redial = "30s"  # Increase from default 20s

# Or in gNMIc
gnmic ... --timeout 60s
```

### Issue: TLS/SSL Certificate Errors

**Symptoms:**
```
Error: x509: certificate signed by unknown authority
Error: tls: failed to verify certificate
```

**Solutions:**

**Option 1: Skip certificate verification (testing only)**
```toml
# Telegraf
[[inputs.gnmi]]
  enable_tls = true
  insecure_skip_verify = true
```

```bash
# gNMIc
gnmic ... --insecure
```

**Option 2: Use proper certificates (production)**
```toml
[[inputs.gnmi]]
  enable_tls = true
  tls_ca = "/path/to/ca.pem"
  tls_cert = "/path/to/client-cert.pem"
  tls_key = "/path/to/client-key.pem"
```

---

## Authentication Problems

### Issue: Authentication Failed

**Symptoms:**
```
Error: authentication failed
Error: invalid username or password
```

**Solutions:**

**1. Verify credentials**
```toml
# Check username/password in config
[[inputs.gnmi]]
  username = "admin"
  password = "correct-password"  # Verify this!
```

**2. Check AAA configuration on device**
```cisco
! Verify AAA is configured
show running-config | section aaa

! Basic AAA config for local auth
aaa new-model
aaa authentication login default local
aaa authorization exec default local

! Create local user
username admin privilege 15 secret MyPassword
```

**3. Verify user has correct privileges**
```cisco
! Check user privilege level
show privilege

! User needs privilege 15 for gNMI
username admin privilege 15 secret Password
```

### Issue: AAA Server Unreachable

**Symptoms:**
```
Error: authentication timeout
```

**Solutions:**

```cisco
! Add fallback to local authentication
aaa authentication login default group tacacs+ local
aaa authorization exec default group tacacs+ local

! Or use local authentication for testing
aaa authentication login default local
```

---

## Configuration Issues

### Issue: Multiple [[inputs.gnmi]] Sections - CRITICAL BUG

**Symptoms:**
- Some subscriptions return 0 bytes
- No error messages in logs
- Unpredictable subscription failures
- `oc_platform.log` and `oc_system.log` are empty

**Diagnosis:**
```bash
# Check config for multiple input sections
grep -c "^\[\[inputs.gnmi\]\]" telegraf-gnmi-advanced.conf
# If output > 1, you have the problem!
```

**Root Cause:**
Telegraf gNMI plugin does not properly handle multiple `[[inputs.gnmi]]` sections. This causes some subscriptions to fail silently with no error messages.

**❌ BROKEN Configuration:**
```toml
# DON'T DO THIS
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "password"

  [[inputs.gnmi.subscription]]
    name = "oc_platform"
    origin = "openconfig"
    path = "/components"

[[inputs.gnmi]]  # SECOND SECTION - CAUSES FAILURES!
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "password"

  [[inputs.gnmi.subscription]]
    name = "cpu_usage"
    origin = "legacy"
    path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"
```

**✅ WORKING Configuration:**
```toml
# ONE [[inputs.gnmi]] section with ALL subscriptions
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]
  username = "admin"
  password = "password"
  encoding = "json_ietf"
  enable_tls = true
  insecure_skip_verify = true

  # OpenConfig subscriptions
  [[inputs.gnmi.subscription]]
    name = "oc_platform"
    origin = "openconfig"
    path = "/components"
    subscription_mode = "sample"
    sample_interval = "30s"

  [[inputs.gnmi.subscription]]
    name = "oc_system"
    origin = "openconfig"
    path = "/system"
    subscription_mode = "sample"
    sample_interval = "30s"

  # Cisco Native subscriptions
  [[inputs.gnmi.subscription]]
    name = "cpu_usage"
    origin = "legacy"
    path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"
    subscription_mode = "sample"
    sample_interval = "10s"

  # Add tags once at the end
  [inputs.gnmi.tags]
    source = "10.85.134.65"
    device_type = "c9300"
```

**Verification:**
```bash
# 1. Fix config (consolidate to single section)
# 2. Test configuration
telegraf --config telegraf-gnmi-advanced.conf --test

# 3. Run for 30 seconds
telegraf --config telegraf-gnmi-advanced.conf &
TELEGRAF_PID=$!
sleep 30
kill $TELEGRAF_PID

# 4. Check ALL files have data
ls -lh /tmp/*.log
# All files should be > 0 bytes!

# 5. Verify line counts
wc -l /tmp/oc_platform.log /tmp/oc_system.log
# Should show multiple lines, not 0
```

### Issue: Typo in enable_tls Parameter

**Symptoms:**
```
Error: unknown field "tls_enable"
```

**Solution:**
```toml
# WRONG
[[inputs.gnmi]]
  tls_enable = true  # ❌ Invalid parameter

# CORRECT
[[inputs.gnmi]]
  enable_tls = true  # ✅ Correct parameter
```

### Issue: Wrong Origin Format

**Symptoms:**
```
Error: subscription failed
Error: unknown origin
```

**Solutions:**

```toml
# For OpenConfig models
[[inputs.gnmi.subscription]]
  origin = "openconfig"  # ✅ Correct
  # NOT "openconfig-interfaces" ❌

# For Cisco Native models
[[inputs.gnmi.subscription]]
  origin = "legacy"  # ✅ Correct - use "legacy"
  # NOT "Cisco-IOS-XE-process-cpu-oper" ❌
  path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"
```

**Key Rules:**
- OpenConfig: `origin = "openconfig"`
- Cisco Native: `origin = "legacy"` (module name goes in path)

---

## Data Collection Problems

### Issue: No Data Being Collected

**Symptoms:**
- Telegraf runs but output files are empty
- No metrics in database
- File size is 0 bytes

**Diagnosis Steps:**

**Step 1: Check device supports the path**
```bash
# Test with gNMIc first
gnmic -a 10.85.134.65:9339 \
  -u admin \
  -p password \
  --insecure \
  get \
  --path "openconfig:/components"

# If this works, path is supported
# If this fails, device doesn't support the path
```

**Step 2: Test Telegraf subscription**
```bash
# Run Telegraf in test mode
telegraf --config telegraf-gnmi-basic.conf --test

# Look for output like:
# > oc_platform,host=...,source=... field=value timestamp
```

**Step 3: Check configuration**
```toml
# Verify all required fields
[[inputs.gnmi]]
  addresses = ["10.85.134.65:9339"]  # ✅ Correct format
  username = "admin"                  # ✅ Set
  password = "password"               # ✅ Set
  encoding = "json_ietf"              # ✅ Set
  enable_tls = true                   # ✅ Set

  [[inputs.gnmi.subscription]]
    name = "test"                     # ✅ Set
    path = "/valid/path"              # ✅ Set
    subscription_mode = "sample"      # ✅ Set
    sample_interval = "10s"           # ✅ Set
```

**Step 4: Check for consolidation issue**
```bash
# Count [[inputs.gnmi]] sections
grep -c "^\[\[inputs.gnmi\]\]" your-config.conf

# If > 1, consolidate to single section (see above)
```

### Issue: Partial Data Collection

**Symptoms:**
- Some subscriptions work, others don't
- Specific log files are 0 bytes
- No error messages

**Most Common Cause:** Multiple `[[inputs.gnmi]]` sections (see above)

**Other Causes:**

**1. Device doesn't support the YANG model**
```bash
# Test each path individually with gNMIc
gnmic ... get --path "SUSPECTED_PATH"
```

**2. Path syntax error**
```toml
# WRONG
path = "openconfig:/components"  # ❌ Don't include origin in path

# CORRECT (for OpenConfig)
origin = "openconfig"
path = "/components"  # ✅ Path only

# CORRECT (for Cisco Native)
origin = "legacy"
path = "/process-cpu-ios-xe-oper:cpu-usage/cpu-utilization"  # ✅ Module name in path
```

**3. Sample interval too long**
```toml
# Increase sample frequency for testing
[[inputs.gnmi.subscription]]
  sample_interval = "5s"  # Try shorter interval
```

### Issue: Incorrect Data Format

**Symptoms:**
- Data collected but in wrong format
- Can't parse output
- Missing fields

**Solutions:**

**1. Check encoding**
```toml
[[inputs.gnmi]]
  encoding = "json_ietf"  # Most common for Cisco IOS XE
  # Also try: "json", "proto"
```

**2. Verify output format**
```toml
[[outputs.file]]
  data_format = "influx"  # InfluxDB line protocol
  # Also try: "json", "csv"
```

---

## Performance Issues

### Issue: High CPU Usage

**Symptoms:**
```bash
# Telegraf using >50% CPU
top -pid $(pgrep telegraf)
```

**Causes & Solutions:**

**1. Too many subscriptions**
```toml
# Reduce number of active subscriptions
# Comment out non-essential ones
# [[inputs.gnmi.subscription]]
#   name = "optional_metric"
```

**2. Too frequent sampling**
```toml
# Increase sample intervals
[[inputs.gnmi.subscription]]
  sample_interval = "30s"  # Was 5s
```

**3. Increase batch processing**
```toml
[agent]
  metric_batch_size = 5000     # Increase from 1000
  metric_buffer_limit = 50000  # Increase from 10000
```

### Issue: High Memory Usage

**Symptoms:**
```bash
# Telegraf using >500MB RAM
ps aux | grep telegraf
```

**Solutions:**

```toml
[agent]
  # Limit buffer size
  metric_buffer_limit = 10000  # Decrease if needed

  # Flush more frequently
  flush_interval = "10s"       # Decrease from 60s
```

### Issue: Slow Data Collection

**Symptoms:**
- Long delays between samples
- Metrics arrive late

**Solutions:**

```toml
# Reduce processing overhead
[agent]
  collection_jitter = "0s"     # Remove jitter
  flush_jitter = "0s"          # Remove jitter

# Check network latency
[[inputs.gnmi]]
  redial = "10s"               # Reduce redial time
```

---

## Device-Specific Issues

### Issue: IOS XE Version Too Old

**Symptoms:**
```
Error: path not supported
Error: model not found
```

**Solutions:**

**Minimum versions:**
- gNMI support: IOS XE 16.12+
- Full OpenConfig: IOS XE 17.3+
- Recommended: IOS XE 17.6+

```cisco
# Check IOS XE version
show version | include Version

# Upgrade if needed
```

### Issue: OpenConfig Models Not Available

**Symptoms:**
```
Error: path not found: /components
Error: unknown YANG model
```

**Check device support:**
```cisco
! Check available YANG models
show platform software yang-management models

! Look for OpenConfig models
show platform software yang-management models | include openconfig
```

**Solutions:**

**Option 1: Use Cisco Native models instead**
```toml
# Instead of OpenConfig platform
[[inputs.gnmi.subscription]]
  name = "environment"
  origin = "legacy"
  path = "/environment-ios-xe-oper:environment-sensors"
```

**Option 2: Upgrade IOS XE**
```cisco
# Newer versions have better OpenConfig support
# Recommend 17.6+
```

### Issue: NETCONF/YANG Not Enabled

**Symptoms:**
```
Error: YANG server not configured
```

**Solution:**
```cisco
configure terminal
  netconf-yang
  netconf-yang feature candidate-datastore
  exit
```

---

## Debugging Techniques

### Enable Debug Logging

**Telegraf:**
```bash
# Run with debug output
telegraf --config telegraf-gnmi-basic.conf --debug

# Or in config
[agent]
  debug = true
  quiet = false
```

**gNMIc:**
```bash
# Run with debug
gnmic ... --debug subscribe --path "..."
```

### Verbose Output

```bash
# Telegraf verbose test
telegraf --config telegraf-gnmi-basic.conf --test --debug 2>&1 | less

# gNMIc verbose
gnmic -a 10.85.134.65:9339 -u admin -p password --insecure \
  --log-level debug \
  subscribe --path "openconfig:/components"
```

### Packet Capture

```bash
# Capture gNMI traffic
sudo tcpdump -i any -w gnmi.pcap port 9339

# Analyze with Wireshark
wireshark gnmi.pcap
```

### Log Analysis

```bash
# Check system logs (Linux)
sudo journalctl -u telegraf -f

# Check for errors
sudo journalctl -u telegraf | grep -i error

# macOS logs
log show --predicate 'process == "telegraf"' --last 1h
```

---

## Common Error Messages

### "subscription failed"

**Causes:**
- Invalid path
- Device doesn't support model
- Wrong origin specified

**Fix:**
Test path with gNMIc, verify origin is correct

### "context deadline exceeded"

**Causes:**
- Network latency
- Device overloaded
- Timeout too short

**Fix:**
Increase timeout, check network

### "unknown field"

**Causes:**
- Typo in configuration parameter
- Using wrong parameter name

**Fix:**
Check Telegraf documentation for correct field names

### "rpc error: code = Unimplemented"

**Causes:**
- Device doesn't support requested operation
- gNMI not fully implemented on device

**Fix:**
Verify device capabilities, try different paths

---

## Best Practices for Troubleshooting

1. **Start Simple**: Test with basic config first
2. **One at a Time**: Test subscriptions individually
3. **Use gNMIc First**: Validate paths before Telegraf
4. **Check Logs**: Always review logs for errors
5. **Test Mode**: Use `--test` before running
6. **Incremental Changes**: Add subscriptions one by one
7. **Document Working Configs**: Save what works
8. **Version Compatibility**: Keep tools and devices updated

## Troubleshooting Checklist

- [ ] Device is reachable (ping)
- [ ] Port 9339 is open (telnet/nc)
- [ ] gNMI is enabled on device
- [ ] Credentials are correct
- [ ] User has privilege 15
- [ ] TLS settings are correct
- [ ] Using single `[[inputs.gnmi]]` section ⭐ CRITICAL
- [ ] Paths tested with gNMIc first
- [ ] Origin is correct (openconfig vs legacy)
- [ ] Encoding is json_ietf
- [ ] Sample intervals are reasonable
- [ ] Output directory is writable
- [ ] No syntax errors in config

---

## Getting Help

If issues persist:

1. **Collect information:**
   ```bash
   # Device version
   show version

   # Telegraf version
   telegraf --version

   # Config (remove passwords)
   cat telegraf-gnmi-basic.conf | grep -v password

   # Test output
   telegraf --config telegraf-gnmi-basic.conf --test 2>&1
   ```

2. **Test with gNMIc:**
   ```bash
   gnmic --debug ... subscribe --path "..." 2>&1
   ```

3. **Check documentation:**
   - Telegraf gNMI plugin docs
   - Cisco MDT documentation
   - Device YANG model reference

---

**Last Updated**: November 2025
**Based on**: Real-world troubleshooting of IOS XE 17.15.1
