# Shell Setup Script

A comprehensive shell setup script for Ubuntu/Debian-based systems that automates the installation and configuration of common development tools and utilities.

## Features

- 🛠️ **Development Tools**
  - Git
  - Build Essential
  - Network Tools
  - Nmap
  - Docker & Docker Compose
  - Python3 & pip3 with venv
  - Go
  - Node.js (via NVM) with PM2

- 🐚 **Shell Customization**
  - Oh My Zsh
  - Agnoster theme
  - Powerline fonts
  - Autojump
  - Autosuggestions

- 🔧 **Optional Components**
  - Nginx
  - UFW (Uncomplicated Firewall)
    - Configurable common ports (HTTP/HTTPS, PostgreSQL, MongoDB)
    - SSH access protection

## Prerequisites

- Ubuntu or Debian-based Linux distribution
- Root or sudo privileges

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/moscowchill/NewShellFix.git
   cd NewShellFix
   ```

2. Make the script executable:
   ```bash
   chmod +x newshellfix.sh
   ```

3. Run the script with sudo:
   ```bash
   sudo ./newshellfix.sh
   ```

## What Gets Installed

### Essential Packages
- curl
- wget
- git
- build-essential
- net-tools
- nmap

### Development Environment
- Docker & Docker Compose
- Python3, pip3, and venv
- Go
- NVM (Node Version Manager)
- Node.js (Latest LTS)
- PM2 (Process Manager)

### Shell Customization
- Zsh
- Oh My Zsh
- Agnoster theme
- Powerline fonts
- Autojump
- Zsh autosuggestions

### Optional Components
- Nginx web server
- UFW (Uncomplicated Firewall)
  - Configurable rules for common services
  - Basic security setup

## Post-Installation

After the script completes:
1. Log out and log back in to:
   - Apply group changes for Docker
   - Start using the new Zsh shell
   - Load NVM environment

2. If you installed UFW, verify your firewall rules:
   ```bash
   sudo ufw status
   ```

## Contributing

Feel free to fork this repository and submit pull requests. You can also open issues for bugs or feature requests.

## License

MIT License

## Notes

- The script will prompt for optional installations (Nginx, UFW)
- All installations are automated with minimal user interaction required
- Default configurations are security-focused
- The script includes error checking and status messages