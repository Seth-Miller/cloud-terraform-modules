packages:
  - git
  - python3-oci

runcmd:
  - su - opc -c 'git config --global credential.helper /usr/share/git_credential_helper/git_credential_helper.py'