write_files:
  - path: /usr/share/git_credential_helper/git_credential_helper.py
    permissions: '0755'
    content: |
      #!/usr/bin/python3
      
      
      import oci
      import sys
      import base64
      import json
      
      
      signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
      secrets_client = oci.secrets.SecretsClient(config={}, signer=signer)
      signer.refresh_security_token()
      
      get_secret_bundle_response = secrets_client.get_secret_bundle(secret_id=var.secret_ocid)
      secret_bundle_content = get_secret_bundle_response.data.secret_bundle_content
      decoded_secret = base64.b64decode(secret_bundle_content.content).decode('utf-8')
      
      if __name__ == "__main__":
          command = sys.argv[1] if len(sys.argv) > 1 else None
      
          if command == "get":
              print(f"username={var.username}")
              print(f"password={decoded_secret}".strip('\n'))
