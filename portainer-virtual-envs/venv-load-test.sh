#!/usr/bin/env bash

# Create unassociated virtual Edge environments in Portainer

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
  if [[ $# -lt 3 ]]; then
    error "Not enough arguments"
    error "Usage: ${0} <PORTAINER_API_URL> <PORTAINER_API_TOKEN> <ENV_COUNT>"
    error "Example: ${0} https://portainer-sdb.local:9443 ptr_VvgSwg+mtdnIxNf4pwrk+h8DG2eDzLo7SDVRWYP3xZ8= 100"
    exit 1
  fi

  PORTAINER_API_URL="${1}"
  PORTAINER_API_TOKEN="${2}"
  ENV_COUNT="${3}"

  [[ "$(command -v http)" ]] || errorAndExit "Unable to find http binary. Please ensure http (httpie) is installed before running this script."

  info "Checking Portainer API connectivity on ${PORTAINER_API_URL}"

  http --verify=no --check-status --ignore-stdin "${PORTAINER_API_URL}"/api/status

  if [[ $? -ne 0 ]]; then
    errorAndExit "Unable to connect to Portainer API on ${PORTAINER_API_URL}"
  fi

  success "Portainer API connectivity OK"

  info "Creating ${ENV_COUNT} virtual environments..."

  for ((i = 0 ; i <= ${ENV_COUNT} ; i++)); do
    http --verify=no --form POST "${PORTAINER_API_URL}"/api/endpoints \
      "X-API-Key:${PORTAINER_API_TOKEN}" \
      Name="venv-${i}" \
      EndpointCreationType=4
  done

  success "Virtual environments created"
}

main "$@"
