#!/bin/bash
set -ueo pipefail

channel="${CHANNEL:-unstable}"
product="${PRODUCT:-supermarket}"
version="${VERSION:-latest}"

echo "--- Installing $channel $product $version"
package_file="$(install-omnibus-product -c "$channel" -P "$product" -v "$version" | tail -n 1)"

if [[ "$package_file" == *.rpm ]]; then
  check-rpm-signed "$package_file"
fi

echo "--- Testing $channel $product $version"

export PATH="/opt/supermarket/bin:/opt/supermarket/embedded/bin:$PATH"
export INSTALL_DIR="/opt/supermarket"

echo ""
echo ""
echo "============================================================"
echo "Verifying ownership of package files"
echo "============================================================"
echo ""

NONROOT_FILES="$(find "$INSTALL_DIR" ! -uid 0 -print)"
if [[ "$NONROOT_FILES" == "" ]]; then
  echo "Packages files are owned by root.  Continuing verification."
else
  echo "Exiting with an error because the following files are not owned by root:"
  echo "$NONROOT_FILES"
  exit 1
fi

echo ""
echo ""
echo "============================================================"
echo "Reconfiguring $product"
echo "============================================================"
echo ""

sudo supermarket-ctl reconfigure || true
sleep 120

echo ""
echo ""
echo "============================================================"
echo "Running verification for $product"
echo "============================================================"
echo ""

sudo supermarket-ctl test -J pedant.xml
