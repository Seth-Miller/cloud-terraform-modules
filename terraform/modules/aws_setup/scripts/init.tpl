packages:
  - git
  - python3-boto3

runcmd:
  - su - ec2-user -c 'git config --global credential.helper /usr/share/git_credential_helper/git_credential_helper.py'
