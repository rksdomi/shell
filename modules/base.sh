system-update() {
    echo.blue "Updating user directories..."
    xdg-user-dirs-update
    cat /home/$USER/.config/user-dirs.dirs

    echo.blue "Updating system..."
    sudo apt update -y

    echo.blue "Upgrading system..."
    sudo apt upgrade -y
}

base-install() {
    base_packages="build-essential dkms linux-headers-$(uname -r) ufw $(tasksel --task-packages standard) psmisc git"
    if (( is_laptop == 0 )); then
        base_packages="$base_packages $(tasksel --task-packages laptop)"
    fi

    echo.blue "Installing base packages..."
    sudo apt install $base_packages -y

    echo.blue "Setting up default firewall policies..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw deny telnet comment "Deny Telnet"
    sudo ufw deny ssh comment "Deny SSH"
}

base_setup() {
    system-update
    base-install
}