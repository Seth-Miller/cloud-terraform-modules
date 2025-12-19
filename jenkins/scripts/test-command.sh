#!/bin/sh

getCredentialCommand='/usr/share/git_credential_helper/git_credential_helper.py get'

# create ssh agent
eval $(ssh-agent -s)
# add private key to ssh agent
terraform -chdir=${1} output -raw private_key_pem | ssh-add -
# execute command
sshOut=$(ssh -o StrictHostKeyChecking=no ec2-user@$(terraform -chdir=${1} output -raw public_ip) $getCredentialCommand)
# kill ssh agent
ssh-agent -k

# check output of command
[[ "$sshOut" != $'username=testuser\npassword=testpassword' ]] && exit 1