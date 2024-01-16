wmninst() {
    echo.blue "Installing video components..."
    sudo aptitude install xserver-xorg-core xserver-xorg-input-evdev x11-xserver-utils x11-xkb-utils x11-utils \
    lightdm slick-greeter i3 dunst rofi polybar -y

    read -p "Press any key to continue "
}

wpginst() {
    sudo aptitude install python3.11-venv xsettingsd gtk2-engines-murrine imagemagick mpd
    python3 -m venv $HOME/pvenv
    $HOME/pvenv/bin/pip3 install --upgrade wheel
    $HOME/pvenv/bin/pip3 install pywal wpgtk
    source $HOME/pvenv/bin/activate && $HOME/pvenv/bin/wpg-install.sh -grIpd && deactivate
    cp -r $script_dir/dotfiles/* $HOME/.config
    source $HOME/pvenv/bin/activate && wpg -s $script_dir/backgrounds/background.jpg && deactivate

    read -p "Press any key to continue "
}

video_setup() {
    wmninst
    wpginst
}