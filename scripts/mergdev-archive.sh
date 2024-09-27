#!/bin/bash
################################################################################
# Script to setup, remove, or check status of the mergdev apt repository
#
#   07 November, 2023 - E M Thornber
#   Created from kitware-archive.sh (authors of CMake)
#
#   30 August, 2024 - E M Thornber
#   Updated Raspbian release to Bookworm
#
#   27 September, 2024 - Claude Dev
#   Added support for future releases, improved error handling, and added version tracking
#   Implemented getopts for argument parsing and added 'install', 'remove', and 'status' options
################################################################################

# Script version
VERSION="1.4.0"

# -e - exit immediately if a command exits with non-zero status
# -u - treat unset variables as an error when substituting
set -eu

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Function to display help
help() {
  echo "Usage: $0 [-h] [-R <raspbian-release>] [-i | -r | -s]" >&2
  echo "Version: $VERSION" >&2
  echo "This script sets up, removes, or checks the status of the mergdev apt repository for Raspbian systems." >&2
  echo "It can install necessary packages, retrieve the GPG key, and configure the apt source," >&2
  echo "remove the repository configuration and GPG key, or check the current status." >&2
  echo >&2
  echo "Options:" >&2
  echo "  -h    Display this help message" >&2
  echo "  -R    Specify Raspbian release (default: current system release)" >&2
  echo "  -i    Install the repository" >&2
  echo "  -r    Remove the repository" >&2
  echo "  -s    Check the status of the repository" >&2
}

# Check if script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  log "Error: This script must be run with sudo privileges."
  exit 1
fi

# Initialize variables
release=""
install_flag=false
remove_flag=false
status_flag=false

# Parse command line options
while getopts ":hR:irs" opt; do
  case ${opt} in
    h )
      help
      exit 0
      ;;
    R )
      release=$OPTARG
      ;;
    i )
      install_flag=true
      ;;
    r )
      remove_flag=true
      ;;
    s )
      status_flag=true
      ;;
    \? )
      log "Error: Invalid option: $OPTARG" >&2
      help
      exit 1
      ;;
    : )
      log "Error: Option -$OPTARG requires an argument." >&2
      help
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check for mutually exclusive options
if (( (install_flag + remove_flag + status_flag) > 1 )); then
  log "Error: Options -i, -r, and -s are mutually exclusive. Please use only one."
  help
  exit 1
fi

# If release is not specified, determine it from the system
if [ -z "$release" ]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "raspbian" ]; then
      log "Error: This is not a Raspbian system. Aborting."
      exit 1
    fi
    release=$VERSION_CODENAME
  else
    log "Error: Unable to determine Raspbian release. Please specify with -R option."
    exit 1
  fi
fi

# Support for current and future Raspbian releases
case "${release}" in
  bookworm|trixie|forky)  # 'trixie' and 'forky' are placeholders for future releases
    packages=
    keyring_packages="ca-certificates gpg wget"
    ;;
  *)
    log "Error: Unsupported Raspbian release '${release}'. Aborting."
    exit 1
    ;;
esac

# Main installation function
install_repository() {
  log "Starting repository setup for Raspbian ${release}"
  set -x

  apt-get update
  # shellcheck disable=SC2086
  apt-get install -y ${packages}

  if [ ! -f /usr/share/keyrings/mergdev-archive-keyring.gpg ]; then
    log "Retrieving GPG key"
    if ! wget -O - https://repo.littlegath.org.uk/raspbian/gpg-pubkey.asc 2>/dev/null | gpg --dearmor - > /usr/share/keyrings/mergdev-archive-keyring.gpg; then
      log "Error: Failed to retrieve or process the GPG key"
      exit 1
    fi
  fi

  echo "deb [signed-by=/usr/share/keyrings/mergdev-archive-keyring.gpg] https://repo.littlegath.org.uk/raspbian/ ${release} main" > /etc/apt/sources.list.d/mergdev.list

  apt-get update

  log "Repository setup completed successfully"
}

# Main removal function
remove_repository() {
  log "Starting repository removal for Raspbian ${release}"
  set -x

  # Remove the sources list file
  if [ -f /etc/apt/sources.list.d/mergdev.list ]; then
    rm /etc/apt/sources.list.d/mergdev.list
    log "Removed mergdev.list from /etc/apt/sources.list.d/"
  else
    log "mergdev.list not found in /etc/apt/sources.list.d/. Skipping removal."
  fi

  # Remove the GPG key
  if [ -f /usr/share/keyrings/mergdev-archive-keyring.gpg ]; then
    rm /usr/share/keyrings/mergdev-archive-keyring.gpg
    log "Removed mergdev-archive-keyring.gpg from /usr/share/keyrings/"
  else
    log "mergdev-archive-keyring.gpg not found in /usr/share/keyrings/. Skipping removal."
  fi

  apt-get update

  log "Repository removal completed successfully"
}

# Main status check function
check_status() {
  log "Checking status of mergdev repository"

  local sources_list="/etc/apt/sources.list.d/mergdev.list"
  local gpg_key="/usr/share/keyrings/mergdev-archive-keyring.gpg"

  echo "Repository status:"

  if [ -f "$sources_list" ]; then
    echo "- Sources list file: Present"
    echo "  Content:"
    sed 's/^/    /' "$sources_list"
  else
    echo "- Sources list file: Not present"
  fi

  if [ -f "$gpg_key" ]; then
    echo "- GPG key: Present"
  else
    echo "- GPG key: Not present"
  fi

  if [ -f "$sources_list" ] && [ -f "$gpg_key" ]; then
    echo "Repository appears to be properly installed."
  elif [ ! -f "$sources_list" ] && [ ! -f "$gpg_key" ]; then
    echo "Repository is not installed."
  else
    echo "Repository is in an inconsistent state. Consider reinstalling."
  fi
}

# Main execution
if $install_flag; then
  install_repository
elif $remove_flag; then
  remove_repository
elif $status_flag; then
  check_status
else
  log "No action specified. Use -i to install, -r to remove, or -s to check status of the repository."
  help
fi
