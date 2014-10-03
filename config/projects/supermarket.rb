#
# Copyright 2014 YOUR NAME
#
# All Rights Reserved.
#

name "supermarket"
maintainer "CHANGE ME"
homepage "https://CHANGE-ME.com"

# Defaults to C:/supermarket on Windows
# and /opt/supermarket on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# supermarket dependencies/components
# dependency "somedep"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
