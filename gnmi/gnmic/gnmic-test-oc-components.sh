#!/bin/bash

# gNMIc Test Script - OpenConfig Components Path
# This demonstrates that the device DOES support OpenConfig /components
# even though Telegraf's gNMI plugin doesn't collect data from this path

gnmic -a 10.85.134.65:9339 \
  --username admin \
  --password password \
  --skip-verify \
  --encoding json_ietf \
  subscribe \
  --path 'openconfig:/components' \
  --mode stream \
  --stream-mode sample \
  --sample-interval 10s
