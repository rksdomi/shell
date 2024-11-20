#!/bin/sh

# Install audio components for pipewire
wireplumber_install() {
    echo_blue_message "Installing audio components..."
    sudo apt-get install --no-install-recommends pipewire-media-session pulseaudio-module-bluetooth wireplumber pipewire-pulse pipewire-alsa pipewire-audio-client-libraries libspa-0.2-jack libspa-0.2-bluetooth -y || { echo_blue_message "Failed to install audio components"; exit 1; }
    systemctl --user --now enable wireplumber.service || { echo_blue_message "Failed to enable wireplumber service"; exit 1; }
    sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/ || { echo_blue_message "Failed to copy pipewire configuration"; exit 1; }
    sudo ldconfig || { echo_blue_message "Failed to run ldconfig"; exit 1; }
}

sound_setup() {
    wireplumber_install
}
