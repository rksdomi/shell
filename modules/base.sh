#!/bin/sh

# Update user directories and system
system_update() {
    echo_blue_message "Updating user directories..."
    xdg-user-dirs-update
    cat "/home/$USER/.config/user-dirs.dirs" || { echo_blue_message "Failed to update user directories"; exit 1; }

    echo_blue_message "Updating system..."
    sudo apt-get update -y || { echo_blue_message "Failed to update system"; exit 1; }

    echo_blue_message "Upgrading system..."
    sudo apt-get upgrade -y || { echo_blue_message "Failed to upgrade system"; exit 1; }
}

# Install base packages (minimal for a Debian with i3)
base_install() {
    base_packages="build-essential dkms linux-headers-$(uname -r) ufw"
    
    # Add laptop tools if the system is a laptop
    if [ "$(is_laptop)" -eq 0 ]; then
        base_packages="$base_packages laptop-tools"
    fi

    echo_blue_message "Installing base packages..."
    sudo apt-get install --no-install-recommends "$base_packages" -y || { echo_blue_message "Failed to install base packages"; exit 1; }

    echo_blue_message "Setting up default firewall policies..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw deny telnet comment "Deny Telnet"
    sudo ufw deny ssh comment "Deny SSH"
}

base_setup() {
    system_update
    base_install
}