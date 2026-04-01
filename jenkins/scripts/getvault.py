#!/usr/bin/python
 
#####################################################################
# Script Name: getvault.py
# Description: Imports an OCI vault, encryption key, and secret.
# Author: Seth Miller
# Created: December 15, 2025
# Version: 1.0
# Usage: echo '{"key": "value"}' | ./getvault.py
#####################################################################

import oci
from python_terraform import Terraform
from pathlib import Path
from jsonargparse import ArgumentParser, Namespace
from pythonjsonlogger import jsonlogger
import os, sys, logging, json, time

vault_type = 'oci_kms_vault'
key_type = 'oci_kms_key'
secret_type = 'oci_vault_secret'

debug_mode = os.getenv("DEBUG", "false").lower() in ("true", "1", "yes")

# Setup logger
log_level = logging.DEBUG if debug_mode else logging.INFO
log_format = "%(asctime)s %(levelname)s %(message)s %(name)s"
formatter = jsonlogger.JsonFormatter(log_format, rename_fields={"levelname": "level", "name": "loggerName"})
logHandler = logging.StreamHandler(sys.stderr)
logHandler.setFormatter(formatter)
logging.basicConfig(
    level=log_level,
    format=log_format,
    handlers=[logHandler]
)
logger = logging.getLogger(__name__)

def show_help(parser, error_msg=None):
    """Prints an error message followed by the help menu."""
    if error_msg:
        print(f"ERROR: {error_msg}\n", file=sys.stderr)
    parser.print_help()
    sys.exit(1)

def main():
    # Import Terraform resource into state file
    def import_tf_resource(tf_resource_path, tf_resource_id):
        try:
            logging.debug(f"Terraform state file exists, checking for {tf_resource_path}")

            resources = [r for ms in json.loads(tf_show_stdout)['values']['root_module']['child_modules'] for r in ms['resources']]
            if [r for r in resources if r['address'] == tf_resource_path]:
                logging.info(f"{tf_resource_path} already exists in Terraform state")
                return 0
        except KeyError:
            pass

        logging.info(f"Importing {tf_resource_path} into Terraform state")
        tf.import_cmd(tf_resource_path, tf_resource_id)


    # Define the argument parser
    custom_usage = "echo '{\"vault_name\": \"...\", \"secret_name\": \"...\", \"key_name\": \"...\", \"working_dir\": \"...\", \"module_name\": \"...\", \"vault_resource_name\": \"...\", \"key_resource_name\": \"...\", \"secret_resource_name\": \"...\"}' | python %(prog)s"
    parser = ArgumentParser(
        description="OCI & Terraform vault, key, and secret importer",
        usage=custom_usage
    )
    
    # Define your specific arguments
    parser.add_argument("--vault_name", type=str, required=True, help="Name of the vault")
    parser.add_argument("--secret_name", type=str, required=True, help="Name of the secret")
    parser.add_argument("--key_name", type=str, required=True, help="Name of the encryption key")
    parser.add_argument("--working_dir", type=str, required=True, help="Terraform working directory path")
    parser.add_argument("--module_name", type=str, required=True, help="Terraform module name")
    parser.add_argument("--vault_resource_name", type=str, default="id", help="Terraform vault resource name")
    parser.add_argument("--key_resource_name", type=str, default="id", help="Terraform key resource name")
    parser.add_argument("--secret_resource_name", type=str, default="id", help="Terraform secret resource name")

    # Handle help menu explicitly
    if len(sys.argv) > 1 and sys.argv[1] in ["--help", "-h"]:
        parser.print_help()
        sys.exit(0)

    # Check if stdin is empty (isatty is True if it's an interactive terminal with no pipe)
    if sys.stdin.isatty():
        show_help(parser, "No data received via stdin.")

    # Read and validate stdin
    try:
        raw_input = sys.stdin.read().strip()
        # parse_string validates the JSON against the arguments defined above
        sinput = parser.parse_string(raw_input)

    except Exception as e:
        show_help(parser, f"Input Validation Error: {e}")

    module_name = sinput.module_name
    vault_id = sinput.vault_resource_name
    key_id = sinput.key_resource_name
    secret_id = sinput.secret_resource_name

    module_path = '.'.join(['module', module_name])

    logger.info(f"Initializing Terraform in directory: {Path(sinput.working_dir)}")
    tf = Terraform(working_dir=Path(sinput.working_dir))
    tf.init()
    tf_show_return_code, tf_show_stdout, tf_show_stderr = tf.show(json=True)
    
    # Initialize OCI SDK
    config = oci.config.from_file()
    # Use OCI config as dot notation
    oci_config = Namespace(**config)

    # Pull the vaults and secrets from OCI
    kms_vault_client = oci.key_management.KmsVaultClient(config)
    kms_vault_composite = oci.key_management.KmsVaultClientCompositeOperations(kms_vault_client)
    kms_secret_client = oci.vault.VaultsClient(config)
    vault_list = kms_vault_client.list_vaults(compartment_id=oci_config.tenancy).data
    secrets_list = kms_secret_client.list_secrets(compartment_id=oci_config.tenancy).data
    logging.debug(f"Vault list: {vault_list}")
    logging.debug(f"Secrets list: {secrets_list}")
    
    # custom retry constructor was added because of transient service error 409
    #   received when trying to cancel deletion of secret
    retry_strategy_via_constructor = oci.retry.RetryStrategyBuilder(
      # Make up to 10 service calls
      max_attempts_check=True,
      max_attempts=20,
      # Don't exceed a total of 600 seconds for all service calls
      total_elapsed_time_check=True,
      total_elapsed_time_seconds=600,
      # Wait between attempts
      retry_max_wait_between_calls_seconds=60,
      retry_base_sleep_time_seconds=30,
      # Retry on certain service errors:
      #
      #   - 5xx code received for the request
      #   - Any 429 (this is signified by the empty array in the retry config)
      #   - 400s where the code is QuotaExceeded or LimitExceeded
      service_error_check=True,
      service_error_retry_on_any_5xx=True,
      service_error_retry_config={
          409: ['IncorrectState']
      },
      # Use exponential backoff and retry with full jitter, but on throttles use
      # exponential backoff and retry with equal jitter
      backoff_type=oci.retry.BACKOFF_FULL_JITTER_EQUAL_ON_THROTTLE_VALUE
      ).get_retry_strategy()


    # Loop through the vault list
    for vault in vault_list:
        logging.debug(f"Looping through vault OCID: {vault.id}")

        # check for existing vault
        if vault.display_name == sinput.vault_name:
            logging.debug(f"Found a match on vault name: {vault.display_name}")
            vault_resource_path = '.'.join([module_path, vault_type, vault_id])

            # check for existing keys in this vault
            kms_key_client = oci.key_management.KmsManagementClient(config, service_endpoint=vault.management_endpoint)
            keys_list = kms_key_client.list_keys(compartment_id=oci_config.tenancy).data
            logging.debug(f"Keys list for vault {vault.id}: {keys_list}")
    
            # if the vault is active, import it into the terraform state
            if vault.lifecycle_state == oci.key_management.models.Vault.LIFECYCLE_STATE_ACTIVE:
                logging.debug(f"Vault {vault.id} is ACTIVE")
                import_tf_resource(vault_resource_path, vault.id)
    
            # if the vault is pending deletion, activate it and import it into the terraform state
            if vault.lifecycle_state == oci.key_management.models.Vault.LIFECYCLE_STATE_PENDING_DELETION:
                logging.info(f"Vault {vault.id} is PENDING DELETION, changing to ACTIVE")
                kms_vault_composite.cancel_vault_deletion_and_wait_for_state(vault.id,
                    wait_for_states=[oci.key_management.models.Vault.LIFECYCLE_STATE_ACTIVE])
                import_tf_resource(vault_resource_path, vault.id)
    
            # if the key exists, import it into the terraform state
            for key in keys_list:
                logging.debug(f"Looping through key OCID: {key.id}")
                
                if key.display_name == sinput.key_name:
                    logging.debug(f"Found a match on key name: {key.display_name}")
                    enc_key_id = key.id
                    key_resource_path = '.'.join([module_path, key_type, key_id])
                    key_endpoint_path = '/'.join(['managementEndpoint', vault.management_endpoint, 'keys', key.id])
                    import_tf_resource(key_resource_path, key_endpoint_path)
                    break
    
            # check for existing secrets, if it exists, import it into the terraform state
            for secret in secrets_list:
                logging.debug(f"Looping through secret OCID: {secret.id}")

                if secret.vault_id == vault.id and secret.secret_name == sinput.secret_name and secret.key_id == enc_key_id:
                    logging.debug(f"Found a match on secret name: {secret.secret_name}")
                    secret_resource_path = '.'.join([module_path, secret_type, secret_id])

                    # if the secret is active, import it into the terraform state
                    if secret.lifecycle_state == oci.vault.models.Secret.LIFECYCLE_STATE_ACTIVE:
                        logging.debug(f"Secret {secret.id} is ACTIVE")
                        import_tf_resource(secret_resource_path, secret.id)
    
                    # if the secret is pending deletion, activate it and import it into the terraform state
                    if secret.lifecycle_state == oci.vault.models.Secret.LIFECYCLE_STATE_PENDING_DELETION:
                        logging.info(f"Secret {secret.id} is PENDING DELETION, changing to ACTIVE")
                        kms_secret_client.cancel_secret_deletion(secret.id, retry_strategy=retry_strategy_via_constructor)
                        oci.wait_until(
                          kms_secret_client,
                          kms_secret_client.get_secret(secret.id),
                          evaluate_response=lambda r: r.data.lifecycle_state == oci.vault.models.Secret.LIFECYCLE_STATE_ACTIVE,
                          max_wait_seconds=600
                        )
                        import_tf_resource(secret_resource_path, secret.id)
                        oci.wait_until(
                          kms_vault_client,
                          kms_vault_client.get_vault(vault.id),
                          evaluate_response=lambda r: r.data.lifecycle_state == oci.key_management.models.Vault.LIFECYCLE_STATE_ACTIVE,
                          max_wait_seconds=600
                        )
    
                    break
            break

    # Return a result
    sys.stdout.write('{"result": "done"}')

        
if __name__ == "__main__":
    main()
