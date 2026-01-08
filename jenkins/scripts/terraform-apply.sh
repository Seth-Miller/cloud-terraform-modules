#!/bin/sh

#####################################################################
# Script Name: terraform-apply.sh
# Description: This script demonstrates a standard bash header.
# Author: Seth Miller
# Created: December 15, 2025
# Version: 1.0
# Usage: ./terraform-apply.sh [arguments]
#####################################################################

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] terraform_directory

This script is intended to be used in a Jenkins pipeline to initialize
and apply a Terraform configuration. The Terraform directory must be
included as the first argument.

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


terraform -chdir="${1}" init -no-color
terraform -chdir="${1}" apply -no-color -auto-approve 