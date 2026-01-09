#!/bin/sh

#####################################################################
# Script Name: terraform-destroy.sh
# Description: Performs Terraform destroy for Jenkins pipeline.
# Author: Seth Miller
# Created: December 15, 2025
# Version: 1.0
# Usage: ./terraform-destroy.sh terraform_directory
#####################################################################

param_name="terraform_directory"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] ${param_name}

This script is intended to be used in a Jenkins pipeline to destroy a
Terraform configuration. The Terraform directory must be included as
the first argument.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  param=''

  while :; do
    case "${1-}" in
      -h | --help) usage ;;
      -v | --verbose) set -x ;;
      -?*) die "Unknown option: $1" ;;
      *)
        param=${1-null}
        break
        ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: ${param_name}"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"



# script logic here

terraform -chdir="${param}" apply -no-color -auto-approve -destroy