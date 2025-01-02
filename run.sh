#!/bin/bash


# Print the logo
print_logo() {
    cat << "EOF"
    ______                _ __    __     
   / ____/______  _______(_) /_  / /__   
  / /   / ___/ / / / ___/ / __ \/ / _ \  
 / /___/ /  / /_/ / /__/ / /_/ / /  __/  Arch Linux System Crafting Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: typecraft

EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source the package list
if [ ! -f "packages.conf" ]; then
    echo "Error: packages.conf not found!"
    exit 1
fi

source packages.conf

echo "Starting system setup..."

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" &> /dev/null
}

# Function to install packages if not already installed
install_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! is_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing: ${to_install[*]}"
        sudo yay -S --noconfirm "${to_install[@]}"
    fi
}

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    echo "building yay.... yaaaaayyyyy"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "yay is already installed"
fi

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing desktop environment..."
install_packages "${DESKTOP[@]}"

echo "Installing desktop environment..."
install_packages "${OFFICE[@]}"

echo "Installing media packages..."
install_packages "${MEDIA[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
    if ! systemctl is-enabled "$service" &> /dev/null; then
        echo "Enabling $service..."
        sudo systemctl enable "$service"
    else
        echo "$service is already enabled"
    fi
done

echo "Setup complete! You may want to reboot your system."