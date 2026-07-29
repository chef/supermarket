#!/bin/bash
set -ueo pipefail

echo "--- Reconfiguring Supermarket"
if ! sudo supermarket-ctl reconfigure; then
  echo "^^^ +++"
  echo "--- Reconfigure FAILED - dumping chef run logs"
  sudo cat /var/opt/supermarket/cache/chef-stacktrace.out 2>/dev/null || true
  sudo tail -n 200 /var/log/supermarket/reconfigure.log 2>/dev/null || true
  exit 1
fi
sleep 120

echo "--- Running 'supermarket-ctl test'"
sudo supermarket-ctl test
