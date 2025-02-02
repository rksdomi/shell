#!/bin/sh
# Utility functions for all modules

# Check if the script is run as root.
check_root() {
    # id is a POSIX utility.
    if [ "$(id -u)" -eq 0 ]; then
        printf "Please do not run the script as root or with sudo. If any permission is needed, PAM will ask for your password.\n" >&2
        exit 1
    fi
}

# Check if the system is a laptop.
# Returns 1 if it is a laptop (true), and 0 otherwise (false).
is_laptop() {
    # Check in known battery directories.
    for d in /sys/class/power_supply /proc/acpi/battery; do
        if [ -d "$d" ]; then
            # Use shell globbing to check for files matching BAT*.
            set -- "$d"/BAT*
            if [ "$1" != "$d"/BAT* ]; then
                return 1  # true: laptop detected
            fi
        fi
    done

    # Some systems (like WSL) may expose battery status differently.
    for d in /sys/class/power_supply/battery/status /sys/module/battery/initstate; do
        if [ -f "$d" ]; then
            return 1  # true: laptop detected
        fi
    done

    return 0  # false: not a laptop
}

# Echo function for informational messages in blue.
echo_info() {
    # Using printf instead of echo -e for POSIX compliance.
    # "\033[34m" is blue, "\033[0m" resets the color.
    echo
    printf "\033[34m[INFO] %s\033[0m\n" "$1"
    sleep 1
}

# Echo function for warning messages in orange.
echo_warning() {
    # ANSI escape for lighter orange: \033[38;5;214m
    printf "\033[38;5;214m[WARNING] %s\033[0m\n" "$1"
}

# Echo function for success messages in green.
echo_success() {
    printf "\033[32m[SUCCESS] %s\033[0m\n" "$1"
    sleep 1
}

# Echo function for error messages in red.
echo_error() {
    # Output to standard error.
    printf "\033[31m[ERROR] %s\033[0m\n" "$1" >&2
    sleep 5
}
