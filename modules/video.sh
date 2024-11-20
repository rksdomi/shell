#!/bin/sh

# Install minimal Xorg components for i3 setup
xorg_install() {
    echo_blue_message "Installing minimal Xorg components..."
    sudo apt-get install --no-install-recommends xserver-xorg-core x11-xserver-utils xinit i3 dunst rofi polybar -y || { echo_blue_message "Failed to install Xorg components"; exit 1; }
}

# Install wpgtk for wallpaper and theming
wpgtk_install() {
    echo_blue_message "Installing wpgtk and dependencies..."
    sudo apt-get install --no-install-recommends python3-full python3-virtualenv libcairo2-dev libgirepository1.0-dev gir1.2-gtk-3.0 xsettingsd gtk2-engines-murrine imagemagick feh -y || { echo_blue_message "Failed to install wpgtk dependencies"; exit 1; }
    
    echo_blue_message "Creating necessary directories..."
    mkdir -p "$HOME/.config/wpg/templates" "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/rofi" "$HOME/.config/dunst" "$HOME/.local/share/backgrounds"
    cp -r "$SCRIPT_DIR/dotfiles/." "$HOME/" || { echo_blue_message "Failed to copy dotfiles"; exit 1; }
    cp -r "$SCRIPT_DIR/backgrounds/background.jpg" "$HOME/.local/share/backgrounds" || { echo_blue_message "Failed to copy background"; exit 1; }

    echo_blue_message "Cloning wpgtk repository..."
    git clone https://github.com/deviantfero/wpgtk && cd wpgtk || { echo_blue_message "Error cloning wpgtk repository"; exit 1; }

    echo_blue_message "Setting up Python virtual environment..."
    virtualenv "$HOME/.pyvenv" && \
    . "$HOME/.pyvenv/bin/activate" && \
    pip3 install --upgrade wheel pygobject pywal && \
    pip3 install . && \
    bash wpgtk/misc/wpg-install.sh -grIipd && \
    cd "$SCRIPT_DIR" && \
    cp -r "$HOME/.config/wpg/templates" "$SCRIPT_DIR/dotfiles" || { echo_blue_message "Failed to set up wpgtk"; exit 1; }

    echo_blue_message "Cleaning up..."
    rm -rf wpgtk
    "$HOME/.pyvenv/bin/wpg" -s "$HOME/.local/share/backgrounds/background.jpg" && deactivate

    # Add wpgtk background to i3 startup
    echo "exec_always --no-startup-id $HOME/.pyvenv/bin/wpg -rs $HOME/.local/share/backgrounds/background.jpg" >> "$HOME/.config/i3/config" || { echo_blue_message "Failed to add wpgtk to i3 config"; exit 1; }
}

video_setup() {
    xorg_install
    wpgtk_install
}
