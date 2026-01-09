#!/bin/sh

#####################################################################
# Script Name: test-command.sh
# Description: Connects to a remote instance and executes a command.
# Author: Seth Miller
# Created: December 15, 2025
# Version: 1.0
# Usage: ./test-command.sh terraform_directory
#####################################################################

get_credential_command='/usr/share/git_credential_helper/git_credential_helper.py get'
expected_output=$'username=testuser\npassword=testpassword'

param_name="terraform_directory"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

This script is intended to be used in a Jenkins pipeline to connect to
a remote instance over SSH and execute a command to verify that it
runs successfully. The Terraform directory must be included as the
first argument.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  # kill ssh agent
  ssh-agent -k
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

case "$jkEnvironment" in
  AWS)
    sshUser=ec2-user
    ;;
  OCI)
    sshUser=opc
    ;;
  *)
    sshUser=user
    ;;
esac

# create ssh agent
eval $(ssh-agent -s)
# add private key to ssh agent
terraform -chdir=${1} output -raw private_key_pem | ssh-add -
# execute command
sshOut=$(ssh -o StrictHostKeyChecking=no $sshUser@$(terraform -chdir="${1}" output -raw public_ip) $get_credential_command)
# kill ssh agent
ssh-agent -k

# check output of command
[[ "$sshOut" == "$expected_output" ]] && exit 0 || exit 1 