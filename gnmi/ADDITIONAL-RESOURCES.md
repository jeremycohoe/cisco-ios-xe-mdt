# Additional Resources

This gnmi/ directory contains focused, production-ready examples. Additional documentation exists in the parent directory.

## Files in This Directory (gnmi/)

**Ready to use:**
- ✅ [INDEX.md](INDEX.md) - Complete navigation guide
- ✅ [README.md](README.md) - Main documentation
- ✅ [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Command cheat sheet
- ✅ Tested configurations in `telegraf/`
- ✅ Working test scripts in `gnmic/`
- ✅ Complete guides in `docs/`

## Additional Documentation (Parent Directory)

Located in `/Users/jcohoe/Documents/VSCODE/telegraf-gnmi/`:

### For Reference
- **TELEGRAF-GNMI-README.md** - Original comprehensive guide
- **GNMIC-EXAMPLES.md** - Extended gNMIc examples
- **TROUBLESHOOTING.md** - Original troubleshooting guide
- **QUICKSTART.md** - Alternative quick start
- **GITHUB-PUBLISHING-GUIDE.md** - Guide for publishing to GitHub

### Output Examples
- **TELEGRAF-OUTPUT-EXAMPLES.md** - Sample output formats
- **GNMIC-TESTS.md** - Additional gNMIc test cases

### Working Configurations
- **telegraf.conf** - Production configuration (in use)
- **telegraf-gnmi-basic.conf** - Also in `gnmi/telegraf/`
- **telegraf-gnmi-advanced.conf** - Also in `gnmi/telegraf/`

## Recommended Approach

### Option 1: Use This Directory (Recommended)
```bash
cd gnmi/
cat README.md
# Everything you need is here
```

**Advantages:**
- Clean, organized structure
- Focused on essentials
- Easy to share
- Production-ready
- Well-documented

### Option 2: Reference Parent Directory
```bash
cd ..
# Access original documentation and production configs
```

**Use when:**
- Need additional examples
- Want to see output samples
- Publishing to GitHub
- Need extended troubleshooting

## What's the Difference?

| Feature | gnmi/ Directory | Parent Directory |
|---------|----------------|------------------|
| **Focus** | Production-ready examples | Complete documentation |
| **Organization** | Clean structure | Development workspace |
| **Configs** | 2 tested configs | Multiple variants |
| **Documentation** | Focused guides | Comprehensive references |
| **Use Case** | Share with others | Personal reference |
| **Status** | Release-ready | Working directory |

## For Sharing or Publishing

**Recommended: Use the gnmi/ directory**

This directory contains:
- ✅ Clean, organized structure
- ✅ Tested and validated configs
- ✅ Complete documentation
- ✅ Ready for GitHub/sharing
- ✅ Professional presentation

**To share:**
```bash
# Option 1: Share the entire gnmi/ directory
tar -czf cisco-gnmi-examples.tar.gz gnmi/

# Option 2: Create a Git repository
cd gnmi/
git init
git add .
git commit -m "Initial commit: Cisco IOS XE gNMI examples"

# Option 3: Copy to USB/share drive
cp -r gnmi/ /path/to/share/location/
```

## Quick Navigation

**In gnmi/ directory:**
```bash
# Main docs
cat README.md
cat INDEX.md

# Quick reference
cat QUICK-REFERENCE.md

# Test device
cd gnmic && ./gnmic-test-oc-components.sh

# Run Telegraf
cd telegraf
telegraf --config telegraf-gnmi-basic.conf --test
```

**In parent directory:**
```bash
# Extended examples
cd ..
cat GNMIC-EXAMPLES.md
cat TELEGRAF-OUTPUT-EXAMPLES.md

# Production config
telegraf --config telegraf.conf

# Publishing guide
cat GITHUB-PUBLISHING-GUIDE.md
```

## Which Files to Use?

### For Learning gNMI
→ Use **gnmi/README.md** and **gnmi/docs/**

### For Quick Reference
→ Use **gnmi/QUICK-REFERENCE.md**

### For Troubleshooting
→ Use **gnmi/docs/TROUBLESHOOTING.md** (comprehensive)
→ Or **../TROUBLESHOOTING.md** (extended examples)

### For Telegraf Setup
→ Use **gnmi/docs/TELEGRAF-SETUP.md** (complete guide)
→ Or **../TELEGRAF-GNMI-README.md** (alternative)

### For gNMIc Testing
→ Use **gnmi/gnmic/** scripts (working examples)
→ Or **../GNMIC-EXAMPLES.md** (more examples)

### For Production Deployment
→ Use **gnmi/telegraf/telegraf-gnmi-advanced.conf**
→ Or **../telegraf.conf** (current production)

## Keeping Both in Sync

The configs in `gnmi/telegraf/` are copies of the root configs. If you update one:

```bash
# Update root from gnmi/
cp gnmi/telegraf/telegraf-gnmi-basic.conf .
cp gnmi/telegraf/telegraf-gnmi-advanced.conf .

# Or update gnmi/ from root
cp telegraf-gnmi-basic.conf gnmi/telegraf/
cp telegraf-gnmi-advanced.conf gnmi/telegraf/
```

## Recommendation

**For most users**: Stay in the `gnmi/` directory - it has everything you need in a clean, shareable format.

**For advanced users**: Reference parent directory for extended examples and production configs.

---

**Start here**: `cd gnmi/ && cat INDEX.md`
