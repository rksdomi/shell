#!/bin/sh
# Utility functions for all modules

# Check if the script is run as root
check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "Please do not run the script as root or with sudo. If any permission is needed, PAM will ask for your password."
        exit 1
    fi
}

# Check if the system is a laptop (returns 0 if yes)
is_laptop() {
    for d in /sys/class/power_supply /proc/acpi/battery; do
        if [ -d "$d" ] && find "$d" -mindepth 1 -maxdepth 1 -name 'BAT*' -print0 -quit 2>/dev/null | grep -q .; then
            return 0
        fi
    done

    # Some systems (like WSL) may expose battery status differently
    for d in /sys/class/power_supply/battery/status /sys/module/battery/initstate; do
        [ -f "$d" ] && return 0
    done

    return 1
}

# Echo function for informational messages in blue
echo_info() {
    echo -e "\033[34m[INFO] $1\033[0m"
}

# Echo function for error messages in red
echo_error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
}

# Echo function for success messages in green
echo_success() {
    echo -e "\033[32m[SUCCESS] $1\033[0m"
}
