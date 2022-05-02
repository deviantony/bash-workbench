#!/usr/bin/env sh

# Description: Queries a Portainer instance API to create an Edge environment and runs a local Portainer agent
# as a standalone Docker container. The local Portainer agent is then connected to the Edge environment.

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
    error "Usage: ${0} <PORTAINER_API_URL> <PORTAINER_API_TOKEN>"
    error "Example: ${0} https://portainer-sdb.local:9443 ptr_VvgSwg+mtdnIxNf4pwrk+h8DG2eDzLo7SDVRWYP3xZ8="
    exit 1
  fi

  PORTAINER_API_URL="${1}"
  PORTAINER_API_TOKEN="${2}"

  [[ "$(command -v http)" ]] || errorAndExit "Unable to find http binary. Please ensure http (httpie) is installed before running this script."
  [[ "$(command -v jq)" ]] || errorAndExit "Unable to find jq binary. Please ensure jq is installed before running this script."
  [[ "$(command -v uuidgen)" ]] || errorAndExit "Unable to find uuidgen binary. Please uuidgen is installed before running this script."
  info "Checking Portainer API connectivity on ${PORTAINER_API_URL}"

  http --verify=no --check-status --ignore-stdin "${PORTAINER_API_URL}"/api/status

  if [[ $? -ne 0 ]]; then
    errorAndExit "Unable to connect to Portainer API on ${PORTAINER_API_URL}"
  fi

  success "Portainer API connectivity OK"

  env_id=$(uuidgen)

  info "Sending environment creation request to Portainer API (name=${env_id})..."

  response=$(http --verify=no --ignore-stdin --body --form POST "${PORTAINER_API_URL}"/api/endpoints \
    "X-API-Key:${PORTAINER_API_TOKEN}" \
    Name="venv-${env_id}" \
    URL="${PORTAINER_API_URL}" \
    EndpointCreationType=4)

  edge_key=$(echo "${response}" | jq -r '.EdgeKey')

  info "Deploying Portainer Edge agent using Edge key ${edge_key}..."
  
  docker run -i \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -v /:/host \
    -v portainer_agent_data:/data \
    --restart always \
    -e EDGE=1 \
    -e EDGE_ID=${env_id} \
    -e EDGE_KEY=${edge_key} \
    -e EDGE_INSECURE_POLL=1 \
    --name portainer_edge_agent \
    portainer/agent:2.11.1

  success "Virtual environment created"
}

main "$@"