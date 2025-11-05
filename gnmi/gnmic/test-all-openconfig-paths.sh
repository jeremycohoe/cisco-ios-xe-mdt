#!/bin/bash

# Test all OpenConfig paths to verify device support
# Run each test for 15 seconds to see sample data

echo "=== Testing OpenConfig /interfaces/interface/state/counters ==="
timeout 15 gnmic -a 10.85.134.65:9339 \
  --username admin \
  --password password \
  --skip-verify \
  --encoding json_ietf \
  subscribe \
  --path 'openconfig:/interfaces/interface/state/counters' \
  --mode stream \
  --stream-mode sample \
  --sample-interval 10s | head -50

echo ""
echo "=== Testing OpenConfig /components ==="
timeout 15 gnmic -a 10.85.134.65:9339 \
  --username admin \
  --password password \
  --skip-verify \
  --encoding json_ietf \
  subscribe \
  --path 'openconfig:/components' \
  --mode stream \
  --stream-mode sample \
  --sample-interval 10s | head -50

echo ""
echo "=== Testing OpenConfig /system ==="
timeout 15 gnmic -a 10.85.134.65:9339 \
  --username admin \
  --password password \
  --skip-verify \
  --encoding json_ietf \
  subscribe \
  --path 'openconfig:/system' \
  --mode stream \
  --stream-mode sample \
  --sample-interval 10s | head -50

echo ""
echo "All OpenConfig paths tested!"
