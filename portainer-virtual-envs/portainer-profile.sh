#!/usr/bin/env bash

# Description:

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
  
  info "Checking Portainer API connectivity on ${PORTAINER_API_URL}"

  http --verify=no --check-status --ignore-stdin "${PORTAINER_API_URL}"/api/status

  if [[ $? -ne 0 ]]; then
    errorAndExit "Unable to connect to Portainer API on ${PORTAINER_API_URL}"
  fi

  success "Portainer API connectivity OK"

  info "Sending profile requests..."

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/mutex \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_mutex-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/block \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_block-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/allocs \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_allocs-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/goroutine \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_goroutine-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/heap \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_heap-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/profile \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_profile-$(date '+%d%m%Y-%H%M%S').bin

  http --verify=no --ignore-stdin GET "${PORTAINER_API_URL}"/debug/pprof/trace \
    "X-API-Key:${PORTAINER_API_TOKEN}" > pprof_trace-$(date '+%d%m%Y-%H%M%S').bin

  success "Profiling successfully terminated"
}

main "$@"
