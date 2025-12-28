#!/bin/sh

getCredentialCommand='/usr/share/git_credential_helper/git_credential_helper.py get'
expectedOutput=$'username=testuser\npassword=testpassword'

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
#echo "ssh -o StrictHostKeyChecking=no $sshUser@$(terraform -chdir=\"${1}\" output -raw public_ip) $getCredentialCommand"
sshOut=$(ssh -o StrictHostKeyChecking=no $sshUser@$(terraform -chdir="${1}" output -raw public_ip) $getCredentialCommand)
# kill ssh agent
ssh-agent -k

# check output of command
[[ "$sshOut" == "$expectedOutput" ]] && exit 0 || exit 1 
