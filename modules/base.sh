sysupdt() {
    xdg-user-dirs-update
    sudo apt install aptitude

    echo.blue "Updating system..."
    sudo aptitude update -y

    echo.blue "Upgrading system..."
    sudo aptitude safe-upgrade -y

    echo.blue "Upgrading distribution..."
    sudo aptitude full-upgrade -y

    read -p "Press any key to continue "
}

fwlinst() {
    echo.blue "Installing Uncomplicated Firewall and applying default policies..."
    sudo aptitude install ufw -y
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw deny telnet comment "Deny Telnet"
    sudo ufw deny ssh comment "Deny SSH"

    read -p "Press any key to continue "
}

lkhinst() {
    echo.blue "Installing Linux Kernel headers..."
    sudo aptitude install build-essential linux-headers-$(uname -r) -y

    read -p "Press any key to continue "
}

bsuinst() {
    echo.blue "Installing Tasksel STANDARD task..."
    sudo tasksel install task standard

    if (( is_laptop == 0 )); then
        echo.blue "Installing Tasksel LAPTOP task..."
        sudo tasksel install task laptop
    fi

    sudo aptitude install git -y

    read -p "Press any key to continue "
}

base_setup() {
    sysupdt
    fwlinst
    lkhinst
    bsuinst
}