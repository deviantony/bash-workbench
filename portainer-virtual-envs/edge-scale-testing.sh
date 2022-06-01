#!/usr/bin/env bash

# Create virtual Edge environments in Portainer
# Use this script alongside a Portainer BE instance configured with AEEC and no waiting room

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

main() {
    if [[ $# -lt 2 ]]; then
        error "Not enough arguments"
        error "Usage: ${0} <ENV_COUNT> <EDGE_KEY> <START_IDX:optional>"
        error "Example: ${0} 1000 <portainer-instance-edge-key> 100"
        exit 1
    fi

    ENV_COUNT="${1}"
    EDGE_KEY="${2}"
    START_IDX="${3:-1}"

    idx=$START_IDX
    total=$((idx + (ENV_COUNT - 1)))

    info "Creating ${ENV_COUNT} virtual environments..."

    for ((i = idx ; i <= total ; i++)); do
        
        docker run --privileged -itd \
        -e EDGE_KEY=${EDGE_KEY} \
        deviantony/virtualenv-edge:20-dind

        info "Virtual environment #${i} created"

        sleep 1
    done

  success "All virtual environments created"
}

main "$@"
