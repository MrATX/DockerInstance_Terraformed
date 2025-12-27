#!/bin/bash
# Set to exit on error
set -e

# Update apt
echo "=== Updating apt ==="
sudo apt update

# Install Git
echo "=== Installing Git ==="
sudo apt install -y git

# Clone Docker install repo
echo "=== Cloning Repo ==="
cd /
sudo mkdir repos
cd /repos
sudo git clone https://github.com/MrATX/MrATXDockerScripts.git

# Install Docker
echo "=== Installing Docker ==="
cd /repos/MrATXDockerScripts/
sudo chmod +x install-docker.sh ./install-docker.sh
./install-docker.sh