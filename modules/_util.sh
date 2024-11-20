#!/bin/sh

# Check if the script is run as root
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "Please do not run the script as the root user nor using sudo command. If any permission is needed, PAM will ask for your password."
        exit 1
    fi
}

# Check if the system is a laptop
is_laptop() {
    d=""
    for d in /sys/class/power_supply /proc/acpi/battery; do
        [ -d "$d" ] && find "$d" -mindepth 1 -maxdepth 1 -name 'BAT*' -print0 -quit 2>/dev/null | grep -q . && return 0
    done

    # Checking /sys/class/power_supply/battery/status for WSL
    for d in /sys/class/power_supply/battery/status /sys/module/battery/initstate; do
        [ -f "$d" ] && return 0
    done

    return 1
}

# Echo function for blue messages
echo_blue_message() {
    # Basic blue text output for status messages
    echo "[INFO] $1"
}