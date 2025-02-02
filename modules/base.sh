#!/bin/sh
# Base system update and package installation functions

# Exit immediately on error and treat unset variables as errors.
set -eu

system_update() {
    echo_info "Updating user directories..."

    xdg-user-dirs-update
    if [ ! -f "/home/$USER/.config/user-dirs.dirs" ]; then
        echo_error "User directories file not found"
        exit 1
    fi

    echo_info "Updating system package lists..."
    if ! sudo apt-get update -y; then
        echo_error "Failed to update system package lists"
        exit 1
    fi

    echo_info "Upgrading installed packages..."
    if ! sudo apt-get upgrade -y; then
        echo_error "Failed to upgrade system"
        exit 1
    fi

    echo_success "System updated!"
}

base_install() {
    echo_info "Starting base install..."

    base_packages="build-essential dkms linux-headers-$(uname -r) ufw fail2ban unattended-upgrades apt-listchanges apparmor apparmor-profiles apparmor-utils policykit-1-gnome"
    # Temporarily disable exit-on-error so that is_laptop's nonzero return is captured.
    set +e
    is_laptop
    ret="$?"
    set -e

    # Since we flipped the logic, a return of 1 means it IS a laptop.
    if [ "$ret" -eq 1 ]; then
        base_packages="$base_packages tlp acpi"
        echo_info "Laptop detected; adding tlp and acpi to base packages"
    else
        echo_info "Non-laptop system detected"
    fi

    echo_info "Installing base packages: $base_packages"
    if ! sudo apt-get install $base_packages -y; then
        echo_error "Failed to install base packages"
        exit 1
    fi

    # Enable AppArmor and load necessary profiles.
    echo_info "Enabling and configuring AppArmor..."
    sudo systemctl enable apparmor
    sudo systemctl start apparmor

    # Use 'aa-enforce' only if apparmor-utils is installed.
    if command -v aa-enforce >/dev/null 2>&1; then
        echo_info "Enforcing AppArmor profiles..."
        sudo aa-enforce /etc/apparmor.d/*
    else
        echo_info "'aa-enforce' command not found, ensuring profiles are loaded manually"
        # Manually load profiles in case aa-enforce is not available.
        for profile in /etc/apparmor.d/*; do
        if [ -f "$profile" ] && grep -q '^#include <tunables/global>' "$profile" 2>/dev/null; then
            sudo apparmor_parser -r "$profile"
        else
            echo_warning "Skipping non-profile or unrecognized file: $profile"
        fi
        done
    fi

    # Enable UFW (Uncomplicated Firewall) and set default policies.
    echo_info "Configuring UFW firewall..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw enable

    # Configure unattended-upgrades for automatic security updates.
    echo_info "Configuring automatic security updates..."
    sudo dpkg-reconfigure --priority=low unattended-upgrades

    # Disable unused filesystems.
    echo_info "Disabling unused filesystems..."
    echo "tmpfs /tmp tmpfs defaults,noatime,nosuid 0 0" | sudo tee -a /etc/fstab
    echo "tmpfs /var/tmp tmpfs defaults,noatime,nosuid 0 0" | sudo tee -a /etc/fstab

    # (Optionally) Disable root login via SSH.
    # echo "Disabling root login via SSH..."
    # sudo sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
    # sudo systemctl reload sshd

    # (Optionally) Disable unused services.
    # echo "Disabling unused services..."
    # sudo systemctl disable avahi-daemon
    # sudo systemctl disable cups
    # sudo systemctl disable nfs-common

    # (Optionally) Set strong password policies.
    # echo_info "Setting strong password policies..."
    # echo "password requisite pam_pwquality.so retry=3 minlen=12 difok=3" | sudo tee -a /etc/pam.d/common-password

    # (Optionally) Set up Logwatch to monitor logs.
    # echo_info "Installing and configuring Logwatch..."
    # sudo apt-get install -y logwatch
    # sudo logwatch --output mail --mailto your-email@example.com --detail high

    # (Optionally) Limit the number of login attempts.
    # echo_info "Limiting login attempts..."
    # echo "auth required pam_tally2.so deny=5 onerr=fail audit" | sudo tee -a /etc/pam.d/common-auth
    # echo "account required pam_tally2.so" | sudo tee -a /etc/pam.d/common-account

    # Configure sysctl for additional hardening.
    echo_info "Configuring sysctl settings for hardening..."
    echo "net.ipv4.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.conf.all.rp_filter = 1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.conf.default.rp_filter = 1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    # Ensure logs are rotated and maintained.
    echo_info "Configuring log rotation..."
    echo "weekly" | sudo tee -a /etc/logrotate.conf
    echo "rotate 4" | sudo tee -a /etc/logrotate.conf
    echo "create" | sudo tee -a /etc/logrotate.conf

    # Remove unnecessary packages.
    echo_info "Removing unnecessary packages..."
    sudo apt-get autoremove --purge -y

    # Cleanup temporary files.
    echo_info "Cleaning up temporary files..."
    sudo rm -rf /tmp/* /var/tmp/*

    # Set appropriate file permissions.
    echo_info "Setting file permissions..."
    sudo chmod 700 /home/* /root
    sudo chmod 755 /etc/ssh /etc/sudoers.d

    # Final check for important services.
    echo_info "Checking important services..."
    sudo systemctl enable fail2ban
    sudo systemctl enable ufw
    sudo systemctl enable apparmor

    echo_info "System hardening is complete!"
    echo_success "Base install complete!"
}

base_setup() {
    system_update
    base_install
}
