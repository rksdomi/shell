#!/bin/sh
# Audio setup functions using Pipewire and WirePlumber

wireplumber_install() {
    echo_info "Installing audio components (Pipewire and WirePlumber)..."
    sudo apt-get install wireplumber pipewire-pulse pipewire-alsa \
        pipewire-audio-client-libraries libspa-0.2-jack libspa-0.2-bluetooth \
        pipewire-media-session- pulseaudio-module-bluetooth- -y || { echo_error "Failed to install audio components"; exit 1; }

    systemctl --user --now enable wireplumber.service || { echo_error "Failed to enable wireplumber service"; exit 1; }
    
    sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/ || { echo_error "Failed to copy Pipewire configuration"; exit 1; }
    sudo ldconfig || { echo_error "Failed to run ldconfig"; exit 1; }

    echo_success "Audio components installed"
}

sound_setup() {
    wireplumber_install
}
