#!/bin/sh
################################################################################
# Script to sign a .deb package and install in APT repository
#
#   12 September, 2024 - E M Thornber
#   Created
#
################################################################################

# Install utility packages if required
sudo apt-get -y install dpkg-sig reprepo


