#!/bin/sh

# Install minimal Xorg components for i3 setup
xorg_install() {
    echo_info "Installing minimal Xorg components..."

    # Install the necessary Xorg components
    sudo apt-get install -y xserver-xorg-core xserver-xorg-input-evdev xserver-xorg-input-libinput xauth \
    x11-xserver-utils x11-xkb-utils x11-utils xinit || {
        echo_error "Failed to install Xorg components"
        exit 1
    }

    echo_success "Minimal Xorg installed!"
}

video_setup() {
    xorg_install
}
