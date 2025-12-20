#!/bin/sh


terraform -chdir="${1}" apply -no-color -auto-approve  -destroy