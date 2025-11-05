# gNMI Examples - Complete Index

Welcome! This directory contains everything you need to collect Model-Driven Telemetry from Cisco IOS XE devices using gNMI.

## 📚 Start Here

### New Users
1. **[README.md](README.md)** - Overview and quick start
2. **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Command cheat sheet
3. **[telegraf/telegraf-gnmi-basic.conf](telegraf/telegraf-gnmi-basic.conf)** - Run your first test

### Experienced Users
1. **[telegraf/telegraf-gnmi-advanced.conf](telegraf/telegraf-gnmi-advanced.conf)** - Production config
2. **[docs/TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md)** - Advanced setup
3. **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Problem solving

## 📖 Documentation Guide

### Getting Started
| Document | Purpose | Read Time |
|----------|---------|-----------|
| [README.md](README.md) | Project overview, quick start | 10 min |
| [QUICK-REFERENCE.md](QUICK-REFERENCE.md) | Common commands and patterns | 5 min |
| [STRUCTURE.md](STRUCTURE.md) | Directory organization | 5 min |

### Configuration Examples
| File | Description | Complexity |
|------|-------------|------------|
| [telegraf-gnmi-basic.conf](telegraf/telegraf-gnmi-basic.conf) | 5 subscriptions | ⭐ Beginner |
| [telegraf-gnmi-advanced.conf](telegraf/telegraf-gnmi-advanced.conf) | 10 subscriptions | ⭐⭐⭐ Advanced |

### Testing Scripts
| Script | What It Tests | Runtime |
|--------|---------------|---------|
| [gnmic-test-oc-components.sh](gnmic/gnmic-test-oc-components.sh) | Platform hardware | 10s |
| [gnmic-test-oc-system.sh](gnmic/gnmic-test-oc-system.sh) | System config | 15s |
| [test-all-openconfig-paths.sh](gnmic/test-all-openconfig-paths.sh) | All OC paths | 30s |

### Detailed Guides
| Document | Topics Covered | Read Time |
|----------|----------------|-----------|
| [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) | Installation, config, deployment | 30 min |
| [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) | Testing, validation, discovery | 25 min |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues, debugging | 35 min |

## 🎯 Common Tasks

### Task: "I want to test if my device supports gNMI"
→ Run: `gnmic/gnmic-test-oc-components.sh`  
→ Read: [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) - Basic Usage section

### Task: "I want to collect basic telemetry"
→ Use: `telegraf/telegraf-gnmi-basic.conf`  
→ Read: [README.md](README.md) - Quick Start section

### Task: "I want production monitoring"
→ Use: `telegraf/telegraf-gnmi-advanced.conf`  
→ Read: [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Production Deployment

### Task: "Nothing is working!"
→ Check: [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Troubleshooting Quick Checks  
→ Read: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Full guide

### Task: "I need specific YANG paths"
→ Read: [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) - YANG Path Discovery  
→ Check: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common Paths

### Task: "My logs are empty (0 bytes)"
→ Read: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Multiple [[inputs.gnmi]] Sections  
→ Check: [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Configuration Patterns

## 🔍 Search Index

### By Topic

**Connection & Authentication**
- [README.md](README.md) - Device Configuration
- [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Connection Settings
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Connection Issues, Authentication Problems

**Configuration**
- [telegraf-gnmi-basic.conf](telegraf/telegraf-gnmi-basic.conf) - Basic example
- [telegraf-gnmi-advanced.conf](telegraf/telegraf-gnmi-advanced.conf) - Advanced example
- [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Configuration Patterns
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Configuration Issues

**Testing & Validation**
- [gnmic-test-oc-components.sh](gnmic/gnmic-test-oc-components.sh) - Platform test
- [gnmic-test-oc-system.sh](gnmic/gnmic-test-oc-system.sh) - System test
- [test-all-openconfig-paths.sh](gnmic/test-all-openconfig-paths.sh) - Comprehensive test
- [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) - Full guide

**Troubleshooting**
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Quick fixes
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Complete guide
- [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Validation section

**Performance**
- [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Performance Tuning
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Performance Issues

**YANG Models**
- [README.md](README.md) - Path examples
- [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) - Path Discovery
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Common Paths

### By Error Message

| Error | See Document | Section |
|-------|--------------|---------|
| "connection refused" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Connection Issues |
| "authentication failed" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Authentication Problems |
| "0 bytes in log files" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Multiple [[inputs.gnmi]] Sections |
| "path not found" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Data Collection Problems |
| "unknown field" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Configuration Issues |
| "tls certificate error" | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Connection Issues |

## 📊 What's Included

- ✅ **2** Validated Telegraf configurations
- ✅ **3** Testing scripts for gNMIc
- ✅ **6** Documentation files
- ✅ **5** Quick reference guides
- ✅ **100%** Tested on IOS XE 17.15.1
- ✅ **All** Common issues documented

## ⚡ Quick Commands

```bash
# Test device connectivity
cd gnmi/gnmic && ./gnmic-test-oc-components.sh

# Test Telegraf config
telegraf --config gnmi/telegraf/telegraf-gnmi-basic.conf --test

# Run basic collection
telegraf --config gnmi/telegraf/telegraf-gnmi-basic.conf

# Check output
ls -lh /tmp/telegraf-gnmi-output.log
```

## 🎓 Learning Path

**Day 1: Understand gNMI**
1. Read [README.md](README.md) overview
2. Review [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
3. Run [gnmic-test-oc-components.sh](gnmic/gnmic-test-oc-components.sh)

**Day 2: Basic Collection**
1. Read [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Basic Configuration
2. Edit [telegraf-gnmi-basic.conf](telegraf/telegraf-gnmi-basic.conf) with your device info
3. Test: `telegraf --config ... --test`
4. Run and verify output

**Day 3: Advanced Features**
1. Review [telegraf-gnmi-advanced.conf](telegraf/telegraf-gnmi-advanced.conf)
2. Read [TELEGRAF-SETUP.md](docs/TELEGRAF-SETUP.md) - Advanced Configuration
3. Add custom subscriptions
4. Configure production output (InfluxDB/Prometheus)

**Ongoing: Troubleshooting**
- Bookmark [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Reference [QUICK-REFERENCE.md](QUICK-REFERENCE.md) for quick fixes
- Use [GNMIC-USAGE.md](docs/GNMIC-USAGE.md) for path validation

## 🔗 External Resources

- [Telegraf Documentation](https://docs.influxdata.com/telegraf/)
- [gNMIc Documentation](https://gnmic.openconfig.net/)
- [Cisco MDT Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/1712/b_1712_programmability_cg/model_driven_telemetry.html)
- [OpenConfig Models](https://github.com/openconfig/public)

---

**Last Updated**: November 2025  
**Total Files**: 11  
**Total Size**: 92KB  
**Tested On**: Cisco IOS XE 17.15.1, Telegraf 1.36.3
