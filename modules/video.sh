xorg-install() {
    echo.blue "Installing video components..."
    sudo apt install xserver-xorg-core xserver-xorg-input-evdev x11-xserver-utils x11-xkb-utils x11-utils xinit rxvt-unicode i3 dunst rofi polybar xterm*- -y
}

wpgtk-install() {
    echo.blue "Installing dependencies..."
    sudo apt install python3-full python3-virtualenv libcairo2-dev libgirepository1.0-dev gir1.2-gtk-3.0 xsettingsd gtk2-engines-murrine imagemagick feh -y
    
    echo.blue "Creating configuration directories..."
    mkdir -p $HOME/.config/wpg/templates && \
    mkdir -p $HOME/.config/i3 && \
    mkdir -p $HOME/.config/polybar && \
    mkdir -p $HOME/.config/rofi && \
    mkdir -p $HOME/.config/dunst && \
    mkdir -p $HOME/.local/share/backgrounds && \
    cp -r $script_dir/dotfiles/. $HOME/
    cp -r $script_dir/backgrounds/background.jpg $HOME/.local/share/backgrounds

    echo.blue "Cloning wpgtk..."
    git clone https://github.com/deviantfero/wpgtk && cd wpgtk

    echo.blue "Creating Python virtual environment..."
    virtualenv $HOME/.pyvenv && \
    source $HOME/.pyvenv/bin/activate && \
    pip3 install --upgrade wheel && \
    pip3 install pygobject && \ 
    pip3 install pywal && \
    pip3 install . && \
    bash wpgtk/misc/wpg-install.sh -grIipd && \
    cd $script_dir && \
    cp -r $HOME/.config/wpg/templates $script_dir/dotfiles
    rm -r wpgtk && \
    $HOME/.pyvenv/bin/wpg -s $HOME/.local/share/backgrounds/background.jpg && \
    deactivate

    echo $HOME/.config/i3/config >> "exec_always --no-startup-id $HOME/.pyvenv/bin/wpg -rs $HOME/.local/share/backgrounds/background.jpg"
}

video_setup() {
    #xorg-install
    wpgtk-install
}
