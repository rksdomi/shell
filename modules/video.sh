#!/bin/sh

# Install minimal Xorg components for i3 setup
xorg_install() {
    echo_info "Installing minimal Xorg components..."
    sudo apt-get install xserver-xorg-core xserver-xorg-input-evdev xserver-xorg-input-libinput xauth \
    x11-xserver-utils x11-xkb-utils x11-utils xinit i3 dunst rofi polybar -y || { echo_error "Failed to install Xorg components"; exit 1; }

    echo_success "X11 installed"
}

copy_dotfiles() {
    cp "$SCRIPT_DIR/dotfiles/.Xresources" ~/.Xresources

    echo_success "Dotfiles copied" || { echo_error "Failed to copy dotfiles"; exit 1; }
}

video_setup() {
    xorg_install
    copy_dotfiles
}
