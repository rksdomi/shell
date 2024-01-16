wplinst() {
    echo.blue "Installing audio components..."
    sudo aptitude install pipewire-media-session- pulseaudio-module-bluetooth- wireplumber pipewire-pulse pipewire-alsa \
    pipewire-audio-client-libraries libspa-0.2-jack libspa-0.2-bluetooth -y
    systemctl --user --now enable wireplumber.service
    sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
    sudo ldconfig

    read -p "Press any key to continue "
}

sound_setup() {
    wplinst
}