#!/bin/sh
# Main script

# Exit immediately on error and treat unset variables as errors.
set -eu

# Determine the absolute path of the script's directory.
# This is done by changing to the directory containing "$0" and printing the working directory.
SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
export SCRIPT_DIR

# Function to load a module with error checking.
load_module() {
    module_path="$1"
    if [ ! -r "$module_path" ]; then
        echo "Error: Module '$module_path' not found or not readable." >&2
        exit 1
    fi
    . "$module_path"
}

# Source common modules.
load_module "$SCRIPT_DIR/modules/_util.sh"
load_module "$SCRIPT_DIR/modules/base.sh"
load_module "$SCRIPT_DIR/modules/sound.sh"
load_module "$SCRIPT_DIR/modules/video.sh"
load_module "$SCRIPT_DIR/modules/window.sh"

# Ensure that the check_root function is available.
if ! command -v check_root >/dev/null 2>&1; then
    echo "Error: check_root function not defined. Ensure that _util.sh defines it." >&2
    exit 1
fi

# ASCII Art Header
echo "\033[34m
██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗     ██╗██████╗ 
██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║    ███║╚════██╗
██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║    ╚██║ █████╔╝
██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║     ██║██╔═══╝ 
██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║     ██║███████╗
╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝     ╚═╝╚══════╝
\033[0m"

# Check if running as root (or if a mechanism to escalate privileges is in place).
check_root

# Set up system components.
# Uncomment the following lines as needed.
base_setup
sound_setup
video_setup
window_setup

echo
# (Optionally) Autoremove packages no longer needed.
if command -v sudo >/dev/null 2>&1; then
    sudo apt-get autoremove -y
else
    echo_warning "sudo command not found. Skipping 'apt-get autoremove'." >&2
fi