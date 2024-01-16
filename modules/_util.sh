check_root() {
    if (( $EUID == 0 )); then
        echo "Please do not run the script as the root user nor using sudo command. If any permission is needed, the terminal will ask for your password."
        exit
    fi
}

is_laptop() {
    local d
    for d in /sys/class/power_supply /proc/acpi/battery; do
        [[ -d "$d" ]] && find $d -mindepth 1 -maxdepth 1 -name 'BAT*' -print0 -quit 2>/dev/null | grep -q . && return 0
    done

    # note we're checking /sys/class/power_supply/battery/status for WSL
    for d in /sys/class/power_supply/battery/status /sys/module/battery/initstate; do
        [[ -f "$d" ]] && return 0
    done

    return 1
}

# Echo functions 
echo.blue() {
    echo -e "\n$(tput setaf 4)$(tput bold)[$1]$(tput sgr 0)"
}