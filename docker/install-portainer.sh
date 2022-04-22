#!/usr/bin/env bash

# Install Docker + Portainer on Ubuntu
# Must run with sudo

set -e

# logging

ESeq="\x1b["
RCol="$ESeq"'0m'
BIRed="$ESeq"'1;91m'
BIGre="$ESeq"'1;92m'
BIYel="$ESeq"'1;93m'
BIWhi="$ESeq"'1;97m'

printSection() {
  echo -e "${BIYel}>>>> ${BIWhi}${1}${RCol}"
}

info() {
  echo -e "${BIWhi}${1}${RCol}"
}

success() {
  echo -e "${BIGre}${1}${RCol}"
}

error() {
  echo -e "${BIRed}${1}${RCol}"
}

errorAndExit() {
  echo -e "${BIRed}${1}${RCol}"
  exit 1
}

# !logging

if [[ "$EUID" -ne 0 ]]; then
    errorAndExit "Please run this script with sudo privileges."
fi

printSection "Installing Docker"
info "Installing Docker prerequisites"

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

success "System updated"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

info "Setting up Docker apt repo"

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

success "System updated"

info "Installing Docker"

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    docker-ce \
    docker-ce-cli \
    containerd.io

usermod -aG docker $USER

success "Docker installed and configured"

printSection "Installing Portainer"

docker run -d \
    -p 9443:9443 \
    -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    --restart=always \
    --name portainer \
    portainer/portainer-ee:latest

success "Portainer deployed"

exit 0