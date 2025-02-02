#!/bin/bash

# Exit script on any error
set -e

# Update and upgrade system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y

# Install necessary security tools
echo "Installing security tools..."
sudo apt install -y ufw fail2ban unattended-upgrades apt-listchanges apparmor apparmor-profiles apparmor-utils

# Enable AppArmor and load necessary profiles
echo "Enabling and configuring AppArmor..."
sudo systemctl enable apparmor
sudo systemctl start apparmor

# Use 'aa-enforce' only if apparmor-utils is installed
if command -v aa-enforce &> /dev/null
then
    echo "Enforcing AppArmor profiles..."
    sudo aa-enforce /etc/apparmor.d/*
else
    echo "'aa-enforce' command not found, ensuring profiles are loaded manually"
    # Manually load profiles (in case aa-enforce is not available)
    for profile in /etc/apparmor.d/*; do
        sudo apparmor_parser -r "$profile"
    done
fi

# Enable UFW (Uncomplicated Firewall) and set default policies
echo "Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Configure unattended-upgrades for automatic security updates
echo "Configuring automatic security updates..."
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Disable unused filesystems
echo "Disabling unused filesystems..."
echo "tmpfs /tmp tmpfs defaults,noatime,nosuid 0 0" | sudo tee -a /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noatime,nosuid 0 0" | sudo tee -a /etc/fstab

# Disable root login via SSH
echo "Disabling root login via SSH..."
sudo sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
sudo systemctl reload sshd

# Disable unused services
echo "Disabling unused services..."
sudo systemctl disable avahi-daemon
sudo systemctl disable cups
sudo systemctl disable nfs-common

# Set strong password policies
echo "Setting strong password policies..."
echo "password requisite pam_pwquality.so retry=3 minlen=12 difok=3" | sudo tee -a /etc/pam.d/common-password

# Set up logwatch (optional) to monitor logs
echo "Installing and configuring Logwatch..."
sudo apt install -y logwatch
sudo logwatch --output mail --mailto your-email@example.com --detail high

# Limit the number of login attempts (protect against brute force)
echo "Limiting login attempts..."
echo "auth required pam_tally2.so deny=5 onerr=fail audit" | sudo tee -a /etc/pam.d/common-auth
echo "account required pam_tally2.so" | sudo tee -a /etc/pam.d/common-account

# Configure sysctl for additional hardening
echo "Configuring sysctl settings for hardening..."
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

# Ensure logs are rotated and maintained
echo "Configuring log rotation..."
echo "weekly" | sudo tee -a /etc/logrotate.conf
echo "rotate 4" | sudo tee -a /etc/logrotate.conf
echo "create" | sudo tee -a /etc/logrotate.conf

# Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt autoremove --purge -y

# Cleanup temporary files
echo "Cleaning up temporary files..."
sudo rm -rf /tmp/* /var/tmp/*

# Set appropriate file permissions
echo "Setting file permissions..."
sudo chmod 700 /home/* /root
sudo chmod 755 /etc/ssh /etc/sudoers.d

# Final check for important services
echo "Checking important services..."
sudo systemctl enable fail2ban
sudo systemctl enable ufw
sudo systemctl enable apparmor

echo "System hardening is complete!"