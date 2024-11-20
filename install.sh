#!/bin/sh

. "modules/_util.sh"
. "modules/base.sh"
. "modules/sound.sh"
. "modules/video.sh"

EXPORT SCRIPT_DIR="$(realpath "$(dirname "$0")")"

# Ensure the script is not run as root
check_root

# Set up system, sound, and video components
base_setup
sound_setup
video_setup

# Clean up unnecessary packages
sudo apt-get autoremove -y
