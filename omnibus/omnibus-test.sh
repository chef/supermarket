#!/bin/bash
set -ueo pipefail

echo "--- Reconfiguring Supermarket"
sudo supermarket-ctl reconfigure || true
sleep 120

echo "--- Running 'supermarket-ctl test'"
sudo supermarket-ctl test
