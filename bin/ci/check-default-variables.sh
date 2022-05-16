#!/usr/bin/env bash

set -euo pipefail

required_variables=(
  pkg_description
  pkg_license
  pkg_maintainer
  pkg_name
  pkg_origin
  pkg_upstream_url
)

plan_path="$1"

retval=0

echo "--- :open_book: [$plan_path] Checking for default variables"
for var in "${required_variables[@]}"; do
  if ! grep -Eq "^$var" "$plan_path/plan.sh"; then
    echo "    Unable to find '$var' in $*"
    retval=1
  fi
done


if [[ $retval -ne 0 ]]; then
  echo "--- :octogonal_sign: Missing required variables"
  echo "Ensure that your plan.sh contains all of:"
  IFS=$'\n'; echo "${required_variables[*]}"
else
  echo "--- :closed_book: [$plan_path] Found all default variables"
fi

exit $retval
