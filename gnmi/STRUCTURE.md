# Directory Structure

Complete overview of the gnmi/ directory organization.

```
gnmi/
├── README.md                              # Main documentation entry point
├── QUICK-REFERENCE.md                     # Fast reference guide
│
├── telegraf/                              # Telegraf configuration examples
│   ├── telegraf-gnmi-basic.conf          # 5 subscriptions (beginner)
│   └── telegraf-gnmi-advanced.conf       # 10 subscriptions (production)
│
├── gnmic/                                 # gNMIc test scripts
│   ├── gnmic-test-oc-components.sh       # Test OpenConfig platform
│   ├── gnmic-test-oc-system.sh           # Test OpenConfig system
│   └── test-all-openconfig-paths.sh      # Comprehensive OC tests
│
└── docs/                                  # Detailed documentation
    ├── TELEGRAF-SETUP.md                 # Complete Telegraf guide
    ├── GNMIC-USAGE.md                    # gNMIc usage and examples
    └── TROUBLESHOOTING.md                # Common issues and solutions
```

## File Descriptions

### Root Level

**README.md** (Main entry point)
- Quick start guide
- Directory overview
- Usage examples for both Telegraf and gNMIc
- Expected output samples
- Device compatibility matrix

**QUICK-REFERENCE.md** (Cheat sheet)
- Common commands
- Configuration snippets
- Troubleshooting quick checks
- Path reference

### telegraf/ - Configuration Examples

**telegraf-gnmi-basic.conf** (102 lines)
- **Purpose**: Beginner-friendly starter configuration
- **Subscriptions**: 5 total
  - 3 OpenConfig: interfaces, platform, system
  - 2 Cisco Native: CPU, memory
- **Output**: Single file (`/tmp/telegraf-gnmi-output.log`)
- **Use case**: Learning, testing, development
- **Validated**: ✅ All 5 subscriptions tested and working

**telegraf-gnmi-advanced.conf** (214 lines)
- **Purpose**: Production-ready comprehensive monitoring
- **Subscriptions**: 10 total
  - 3 OpenConfig: interfaces, platform, system
  - 7 Cisco Native: CPU, memory, LLDP, CDP, ARP, environment, PoE
- **Output**: 10 separate log files in `/tmp/`
- **Use case**: Production monitoring, full visibility
- **Validated**: ✅ All 10 subscriptions tested and working

**Key Configuration Pattern**: Both files use a **single** `[[inputs.gnmi]]` section with all subscriptions nested inside - this is critical for proper operation.

### gnmic/ - Validation Scripts

**gnmic-test-oc-components.sh** (Executable)
- Tests OpenConfig `/components` path
- Validates platform hardware visibility
- Shows fans, power supplies, chassis info
- Sample interval: 5s
- Use: Quick device capability check

**gnmic-test-oc-system.sh** (Executable)
- Tests OpenConfig `/system` path
- Validates system configuration access
- Shows AAA, users, system settings
- Sample interval: 10s
- Use: System data validation

**test-all-openconfig-paths.sh** (Executable)
- Comprehensive test suite
- Tests all major OpenConfig paths:
  - `/interfaces/interface/state/counters`
  - `/components`
  - `/system`
- Collects 2 samples per path
- Use: Full OpenConfig validation

### docs/ - Detailed Documentation

**TELEGRAF-SETUP.md** (Comprehensive guide)
- Installation instructions (macOS, Linux)
- Configuration walkthroughs
- Pattern explanations (correct vs incorrect)
- Output options (file, InfluxDB, Prometheus)
- Running modes (test, foreground, service)
- Performance tuning
- Best practices
- Example workflows

**GNMIC-USAGE.md** (Reference guide)
- Installation methods
- Command syntax and options
- Testing workflows
- YANG path discovery techniques
- Stream modes explained
- Common patterns
- Advanced multi-device usage
- Filtering and output formatting

**TROUBLESHOOTING.md** (Problem solver)
- Connection issues and fixes
- Authentication problems
- **Critical**: Multiple `[[inputs.gnmi]]` bug explanation
- Configuration errors
- Data collection problems
- Performance optimization
- Device-specific issues
- Debugging techniques
- Error message reference
- Complete troubleshooting checklist

## Usage Patterns

### For Beginners

1. Start with `README.md` - understand the overview
2. Read `QUICK-REFERENCE.md` - get familiar with commands
3. Use `telegraf-gnmi-basic.conf` - test with 5 subscriptions
4. Run validation scripts in `gnmic/` - verify device support
5. Check `TROUBLESHOOTING.md` if issues arise

### For Production Deployment

1. Review `docs/TELEGRAF-SETUP.md` - understand full setup
2. Test with `telegraf-gnmi-basic.conf` first
3. Expand to `telegraf-gnmi-advanced.conf`
4. Customize subscriptions for your needs
5. Deploy with proper output (InfluxDB/Prometheus)
6. Reference `TROUBLESHOOTING.md` for issues

### For Troubleshooting

1. Check `QUICK-REFERENCE.md` - quick fixes
2. Run `gnmic/` scripts - validate device connectivity
3. Review `TROUBLESHOOTING.md` - detailed solutions
4. Check `docs/GNMIC-USAGE.md` - advanced testing

## Customization Points

### Connection Settings (Required)

Edit in both Telegraf configs:
```toml
addresses = ["YOUR_IP:9339"]
username = "YOUR_USER"
password = "YOUR_PASSWORD"
```

### Tags (Recommended)

Customize tags to match your environment:
```toml
[inputs.gnmi.tags]
  source = "device_ip"
  device_type = "model"
  site = "location"
  role = "function"
```

### Subscriptions (Optional)

Add/remove based on needs:
- Comment out unused subscriptions
- Add custom YANG paths
- Adjust sample intervals
- Change subscription modes

## File Sizes

| File | Size | Lines |
|------|------|-------|
| telegraf-gnmi-basic.conf | ~3 KB | 102 |
| telegraf-gnmi-advanced.conf | ~6 KB | 214 |
| TELEGRAF-SETUP.md | ~15 KB | ~500 |
| GNMIC-USAGE.md | ~12 KB | ~400 |
| TROUBLESHOOTING.md | ~14 KB | ~500 |
| README.md | ~8 KB | ~300 |

## Dependencies

### Required
- Telegraf 1.30+ (tested with 1.36.3)
- Cisco IOS XE device with gNMI enabled

### Optional but Recommended
- gNMIc (for testing and validation)
- jq (for JSON parsing)

### For Production
- Time-series database (InfluxDB, Prometheus, etc.)
- Visualization tool (Grafana, etc.)

## Validation Status

All configurations and scripts have been validated on:
- **Device**: Cisco Catalyst 9300X-48HX
- **IOS XE Version**: 17.15.1
- **Telegraf Version**: 1.36.3
- **Date**: November 2025

Test results:
- ✅ Basic config: 5/5 subscriptions working
- ✅ Advanced config: 10/10 subscriptions working
- ✅ All gNMIc scripts functional
- ✅ Documentation accurate and complete

## Updates and Maintenance

To keep this directory current:

1. **Test on new IOS XE versions**
   - Validate paths still work
   - Update compatibility matrix
   - Note any breaking changes

2. **Update for Telegraf changes**
   - Check for new plugin features
   - Update configuration syntax
   - Test new output formats

3. **Expand subscriptions**
   - Add new YANG paths as discovered
   - Document Cisco model updates
   - Test on different device types

4. **Improve documentation**
   - Add real-world examples
   - Document edge cases
   - Include community feedback

## Contributing

If you find issues or have improvements:
- Test thoroughly before sharing
- Document device model and version
- Provide complete error messages
- Share working configurations

---

**Last Updated**: November 2025
**Structure Version**: 1.0
