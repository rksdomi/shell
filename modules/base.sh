#!/bin/sh
# Base system update and package installation functions

system_update() {
    echo_info "Updating user directories..."
    xdg-user-dirs-update
    if [ ! -f "/home/$USER/.config/user-dirs.dirs" ]; then
        echo_error "User directories file not found"
        exit 1
    fi

    echo_info "Updating system package lists..."
    sudo apt-get update -y || { echo_error "Failed to update system package lists"; exit 1; }

    echo_info "Upgrading installed packages..."
    sudo apt-get upgrade -y || { echo_error "Failed to upgrade system"; exit 1; }
    
    echo_success "System updated"
}

base_install() {
    base_packages="build-essential dkms linux-headers-$(uname -r)"

    # Add laptop-specific tools if the system is a laptop
    if is_laptop; then
        base_packages="$base_packages tlp acpi"
    fi

    echo_info "Installing base packages..."
    sudo apt-get install $base_packages -y || { echo_error "Failed to install base packages"; exit 1; }

    echo_success "Base packages installed"
}

base_setup() {
    system_update
    base_install
}
