write_files:
  - path: /usr/share/git_credential_helper/git_credential_helper.py
    permissions: '0755'
    content: |
      #!/usr/bin/python3
      
      
      import boto3
      import json
      import sys
      
      
      secret_name = "${secret_name}"
      region_name = "${region}"
      
      client = boto3.client("secretsmanager", region_name=region_name)
      secret_value = client.get_secret_value(SecretId=secret_name)
      secret_value = json.loads(secret_value['SecretString'])
      username = secret_value['username']
      password = secret_value['password']
      
      
      if __name__ == "__main__":
          command = sys.argv[1] if len(sys.argv) > 1 else None
            
          if command == "get":
              print(f"username={username}")
              print(f"password={password}".strip('\n'))
