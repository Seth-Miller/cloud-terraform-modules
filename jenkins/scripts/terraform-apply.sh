#!/bin/sh


terraform -chdir="${1}" init -no-color
terraform -chdir="${1}" apply -no-color -auto-approve 