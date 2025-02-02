#!/bin/sh
# Main script

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
export SCRIPT_DIR

# Exit script on any error
set -e

# Source common modules
. "$SCRIPT_DIR/modules/_util.sh"
. "$SCRIPT_DIR/modules/base.sh"
. "$SCRIPT_DIR/modules/sound.sh"
. "$SCRIPT_DIR/modules/video.sh"
. "$SCRIPT_DIR/modules/harden.sh"

check_root

# Set up system components
base_setup
sound_setup
video_setup
harden_system

# (Optionally) Autoremove packages no longer needed.
sudo apt-get autoremove -y
