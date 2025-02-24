#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${GREEN}[+] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

print_error() {
    echo -e "${RED}[-] $1${NC}"
}

# Function to check if command was successful
check_status() {
    if [ $? -eq 0 ]; then
        print_message "$1 successful"
    else
        print_error "$1 failed"
        exit 1
    fi
}

# Function to prompt yes/no
prompt_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    # Check if Zsh is installed
    if ! command -v zsh &> /dev/null; then
        print_message "Zsh is not installed. Installing Zsh..."
        sudo apt-get update
        sudo apt-get install -y zsh
    fi

    # Check if Oh My Zsh is already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_message "Installing Oh My Zsh..."
        # Download and execute the install script with the --unattended flag
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Change the default shell to Zsh
        print_message "Changing the default shell to Zsh..."
        chsh -s "$(which zsh)"
    else
        print_message "Oh My Zsh is already installed."
    fi
}

# Function to set Agnoster theme in Oh My Zsh
set_agnoster_theme() {
    print_message "Setting Agnoster theme..."
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc
}

# Function to install Autojump
install_autojump() {
    print_message "Installing Autojump..."
    sudo apt-get install -y autojump
    echo '[[ -s /usr/share/autojump/autojump.sh ]] && . /usr/share/autojump/autojump.sh' >> ~/.zshrc
}

# Function to install Autosuggest plugin
install_autosuggest() {
    print_message "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo 'source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
    echo "plugins=(\${plugins[@]} zsh-autosuggestions)" >> ~/.zshrc
}

# Function to install Powerline Fonts
install_powerline_fonts() {
    print_message "Installing Powerline Fonts..."
    sudo apt install fonts-powerline
}

# New function to install Node.js via NVM
install_node() {
    print_message "Installing NVM and Node.js..."
    # Install NVM as the sudo user, not as root
    sudo -u $SUDO_USER bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'
    
    # Add NVM to current session
    export NVM_DIR="/home/$SUDO_USER/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS version of Node.js as the sudo user
    sudo -u $SUDO_USER bash -c "source $NVM_DIR/nvm.sh && nvm install --lts && nvm use --lts && npm install -g pm2"
    check_status "Node.js and PM2 installation"
    
    # Add NVM initialization to .zshrc if not already present
    if ! grep -q "export NVM_DIR" "/home/$SUDO_USER/.zshrc"; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> "/home/$SUDO_USER/.zshrc"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> "/home/$SUDO_USER/.zshrc"
    fi
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Prompt for optional installations
prompt_yes_no "Do you want to install Nginx?" && install_nginx=true || install_nginx=false
prompt_yes_no "Do you want to install UFW (Uncomplicated Firewall)?" && install_ufw=true || install_ufw=false

# Update system
print_message "Updating system packages..."
apt update && apt upgrade -y
check_status "System update"

# Install essential packages
print_message "Installing essential packages..."
apt install -y curl wget git build-essential net-tools nmap
check_status "Essential packages installation"

# Install Python3 and related packages
print_message "Installing Python3 and related packages..."
apt install -y python3 python3-pip python3-venv
check_status "Python3 installation"

# Install Docker
print_message "Installing Docker..."
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io
check_status "Docker installation"

# Docker post-installation steps
print_message "Setting up Docker post-installation..."
groupadd -f docker
usermod -aG docker $SUDO_USER
systemctl start docker
systemctl enable docker

# Install Docker Compose
print_message "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
check_status "Docker Compose installation"

# Install Go
print_message "Installing Go..."
apt install -y golang-go
check_status "Go installation"

# Install optional packages
if [ "$install_nginx" = true ]; then
    print_message "Installing Nginx..."
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    check_status "Nginx installation"
fi

if [ "$install_ufw" = true ]; then
    print_message "Installing and configuring UFW..."
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    [ "$install_nginx" = true ] && ufw allow 'Nginx Full'
    
    # Common ports prompt
    prompt_yes_no "Do you want to allow HTTP (80) and HTTPS (443)?" && {
        ufw allow http
        ufw allow https
    }
    
    prompt_yes_no "Do you want to allow PostgreSQL (5432)?" && ufw allow 5432/tcp
    prompt_yes_no "Do you want to allow MongoDB (27017)?" && ufw allow 27017/tcp
    
    ufw --force enable
    check_status "UFW installation and configuration"
fi

# Install Oh My Zsh and related components
install_oh_my_zsh
set_agnoster_theme
install_autojump
install_autosuggest
install_powerline_fonts
install_node

print_message "All installations completed successfully!"
print_warning "Please log out and log back in for all changes to take effect."
print_warning "To start using Docker without sudo, log out and log back in."
print_warning "NVM will be available after restarting your shell."
