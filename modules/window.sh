#!/bin/sh

i3_setup() {
    echo_info "Installing i3 and utilities"
    sudo apt install -y i3 dunst rofi polybar rxvt-unicode snapd xterm- || {
        echo_error "Failed to install i3"
        exit 1
    }

    echo_info "Setting up common applications"
    # Install Codium (Open source alternative to VSCode)
    sudo snap install codium --classic || {
        echo_error "Failed to install Codium"
        exit 1
    }

    # Install Brave Browser
    sudo snap install brave || {
        echo_error "Failed to install Brave Browser"
        exit 1
    }

    # Install OpenJDK 21
    wget https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz -P ~/Downloads || {
        echo_error "Failed to download OpenJDK 21"
        exit 1
    }

    tar xzvf ~/Downloads/openjdk-21.0.2_linux-x64_bin.tar.gz -C ~/Downloads/ || {
        echo_error "Failed to extract OpenJDK 21"
        exit 1
    }

    sudo mv ~/Downloads/jdk-21.0.2/ /usr/local/jdk-21 || {
        echo_error "Failed to move OpenJDK 21"
        exit 1
    }

    sudo tee /etc/profile.d/jdk21.sh > /dev/null <<EOF
export JAVA_HOME=/usr/local/jdk-21
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

    sudo chmod 755 /etc/profile.d/jdk21.sh || {
        echo_error "Failed to set permissions for jdk21.sh"
        exit 1
    }

    . /etc/profile.d/jdk21.sh || {
        echo_error "Failed to source jdk21.sh"
        exit 1
    }

    # Install Node.js
    sudo apt install -y nodejs || {
        echo_error "Failed to install Node.js"
        exit 1
    }
}

copy_dotfiles() {
    echo_info "Copying dotfiles"
    cp -rp "$SCRIPT_DIR/dotfiles/." "$HOME/" || {
        echo_error "Failed to copy dotfiles"
        exit 1
    }
    echo_success "Dotfiles copied"
}

window_setup() {
    i3_setup
    copy_dotfiles
}
