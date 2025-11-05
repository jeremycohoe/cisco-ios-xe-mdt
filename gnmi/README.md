# gNMI Examples for Cisco IOS XE

This directory contains working examples for collecting Model-Driven Telemetry from Cisco IOS XE devices using gNMI (gRPC Network Management Interface).

## 📁 Directory Structure

```
gnmi/
├── README.md                    # This file
├── telegraf/                    # Telegraf configuration examples
│   ├── telegraf-gnmi-basic.conf
│   └── telegraf-gnmi-advanced.conf
├── gnmic/                       # gNMIc test scripts
│   ├── gnmic-test-oc-components.sh
│   ├── gnmic-test-oc-system.sh
│   └── test-all-openconfig-paths.sh
└── docs/                        # Documentation
    ├── TELEGRAF-SETUP.md
    ├── GNMIC-USAGE.md
    └── TROUBLESHOOTING.md
```

## 🚀 Quick Start

### Prerequisites

- **Cisco IOS XE Device**: Version 17.3+ recommended (tested on 17.15.1)
- **gNMI Enabled**: Device must have gNMI configured
- **Tools Required**:
  - [Telegraf](https://www.influxdata.com/downloads/) - Data collection agent
  - [gNMIc](https://gnmic.openconfig.net/) (optional) - Testing and validation

### Device Configuration

Ensure your Cisco device has gNMI enabled:

```cisco
gnmi-yang
gnmi-yang server
gnmi-yang port 9339
```

## 📋 What's Included

### Telegraf Examples

| File | Description | Subscriptions | Use Case |
|------|-------------|---------------|----------|
| **telegraf-gnmi-basic.conf** | Beginner-friendly starter config | 5 subscriptions | Learning & testing |
| **telegraf-gnmi-advanced.conf** | Production-ready comprehensive config | 10 subscriptions | Full monitoring |

**Basic Config Subscriptions (5):**
- OpenConfig: Interface counters, Platform components, System info
- Cisco Native: CPU usage, Memory statistics

**Advanced Config Subscriptions (10):**
- All basic subscriptions +
- LLDP neighbors, CDP neighbors, ARP tables
- Environment sensors, PoE data

### gNMIc Test Scripts

| File | Purpose |
|------|---------|
| **gnmic-test-oc-components.sh** | Test OpenConfig platform/components path |
| **gnmic-test-oc-system.sh** | Test OpenConfig system configuration path |
| **test-all-openconfig-paths.sh** | Comprehensive test of all OC paths |

## 🎯 Usage Examples

### Using Telegraf

**Test configuration (no data collection):**
```bash
cd gnmi/telegraf
telegraf --config telegraf-gnmi-basic.conf --test
```

**Run basic collection:**
```bash
telegraf --config telegraf-gnmi-basic.conf
```

**Run advanced collection:**
```bash
telegraf --config telegraf-gnmi-advanced.conf
```

### Using gNMIc

**Test device connectivity:**
```bash
cd gnmi/gnmic
./gnmic-test-oc-components.sh
```

**Test OpenConfig system data:**
```bash
./gnmic-test-oc-system.sh
```

**Run comprehensive path tests:**
```bash
./test-all-openconfig-paths.sh
```

## 📊 Expected Output

### Telegraf Basic Config
Creates a single output file: `/tmp/telegraf-gnmi-output.log`

Sample output shows ~1MB of data with:
- 168 interface counter samples
- 2 CPU usage samples
- 2 memory statistics samples
- 1 platform component sample
- 1 system configuration sample

### Telegraf Advanced Config
Creates 10 separate log files in `/tmp/`:
```
oc_interface_counters.log: 146 KB
oc_platform.log: 97 KB
oc_system.log: 403 KB
cpu_usage.log: 1.3 MB
lldp_neighbors.log: 38 KB
cdp_neighbors.log: 39 KB
arp_data.log: 24 KB
memory_stats.log: 2.6 KB
environment_sensors.log: 10 KB
poe_data.log: 1.9 KB
```

## ⚙️ Configuration Details

### Device Connection Settings (Modify These)

Both Telegraf configs use these default settings:
```toml
addresses = ["10.85.134.65:9339"]
username = "admin"
password = "EN-TME-Cisco123"
```

**Update these values** to match your device's:
- IP address and gNMI port
- Username and password

### Tags (Customize for Your Environment)

Default tags included:
```toml
[inputs.gnmi.tags]
  source = "10.85.134.65"
  device_type = "c9300"
  site = "lab"
```

Customize tags to match your:
- Network topology
- Device types
- Site locations
- Any other metadata needed

## 🔧 Troubleshooting

### Common Issues

**1. Connection refused**
```
Error: connection refused
```
- ✅ Verify gNMI is enabled on device
- ✅ Check firewall/ACL rules
- ✅ Confirm correct IP and port

**2. Authentication failed**
```
Error: authentication failed
```
- ✅ Verify username/password
- ✅ Check AAA configuration on device

**3. Empty data / 0 bytes in logs**
```
oc_platform.log: 0 bytes
```
- ✅ **CRITICAL**: Ensure you're using a SINGLE `[[inputs.gnmi]]` section
- ✅ Multiple `[[inputs.gnmi]]` sections cause subscription failures
- ✅ See docs/TROUBLESHOOTING.md for details

### Validation Steps

**Step 1**: Test with gNMIc first
```bash
cd gnmi/gnmic
./gnmic-test-oc-components.sh
```

**Step 2**: Test Telegraf config
```bash
telegraf --config gnmi/telegraf/telegraf-gnmi-basic.conf --test
```

**Step 3**: Run collection and verify output
```bash
telegraf --config gnmi/telegraf/telegraf-gnmi-basic.conf
# Wait 30 seconds, then check:
ls -lh /tmp/telegraf-gnmi-output.log
```

## 📚 Additional Documentation

- **[TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md)** - Detailed Telegraf setup guide
- **[GNMIC-USAGE.md](docs/GNMIC-USAGE.md)** - gNMIc usage and examples
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## ✅ Validated Devices

These configurations have been tested and validated on:

| Device | IOS XE Version | Status |
|--------|----------------|--------|
| Catalyst 9300X-48HX | 17.15.1 | ✅ Fully tested |
| Catalyst 9300 Series | 17.3+ | ✅ Expected to work |
| Other IOS XE devices | 17.3+ | ⚠️ Should work (verify paths) |

## 🎓 Learning Path

**New to gNMI?** Follow this learning path:

1. **Read** the Telegraf setup documentation
2. **Test** device connectivity with gNMIc scripts
3. **Start** with telegraf-gnmi-basic.conf
4. **Verify** data collection is working
5. **Expand** to telegraf-gnmi-advanced.conf
6. **Customize** for your specific needs

## 🤝 Contributing

Found an issue or have improvements?
- Test thoroughly on your devices
- Document device model and IOS XE version
- Share working configurations
- Report bugs with full context

## 📝 License

These examples are provided as-is for educational and operational use.

## 🔗 Resources

- [Telegraf Documentation](https://docs.influxdata.com/telegraf/)
- [gNMIc Documentation](https://gnmic.openconfig.net/)
- [Cisco Model-Driven Telemetry](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/1712/b_1712_programmability_cg/model_driven_telemetry.html)
- [OpenConfig YANG Models](https://github.com/openconfig/public)

---

**Last Updated**: November 2025
**Tested On**: Cisco IOS XE 17.15.1, Telegraf 1.36.3
