import oci
from python_terraform import Terraform
from pathlib import Path
from jsonargparse import ArgumentParser, Namespace
import os, sys, logging

vault_type = 'oci_kms_vault'
vault_id = 'id'
key_type = 'oci_kms_key'
key_id = 'id'
secret_type = 'oci_vault_secret'
secret_id = 'id'
module_name = 'oci_load_git_secret'
module_path = '.'.join(['module', module_name])

debug_mode = os.getenv("DEBUG", "false").lower() in ("true", "1", "yes")
log_level = logging.DEBUG if debug_mode else logging.INFO

# Setup logger
logging.basicConfig(
    level=log_level,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stderr)]
)
logger = logging.getLogger("OCI_PROCESSOR")

def show_help(parser, error_msg=None):
    """Prints an error message followed by the help menu."""
    if error_msg:
        print(f"ERROR: {error_msg}\n", file=sys.stderr)
    parser.print_help()
    sys.exit(1)

def main():
    # Define the argument parser
    custom_usage = "echo '{\"vault_name\": \"...\", \"secret_name\": \"...\", \"key_name\": \"...\", \"working_dir\": \"...\"}' | python %(prog)s"
    parser = ArgumentParser(
        description="OCI & Terraform vault, key, and secret importer",
        usage=custom_usage
    )
    
    # Define your specific arguments
    parser.add_argument("--vault_name", type=str, required=True, help="Name of the vault")
    parser.add_argument("--secret_name", type=str, required=True, help="Name of the secret")
    parser.add_argument("--key_name", type=str, required=True, help="Name of the encryption key")
    parser.add_argument("--working_dir", type=str, required=True, help="Terraform working directory path")

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


    # Format the working directory path and initialize Terraform directory
    dir_path = sinput.working_dir.split('/')
    logger.debug(f"Directory path split: {dir_path}")
    logger.debug(f"Directory path assembled as 'Path': {Path(*dir_path)}")

    logger.info(f"Initializing Terraform in directory: {sinput.working_dir}")
    tf = Terraform(working_dir=Path(*dir_path))
    tf.init()
    
    # Initialize OCI SDK
    config = oci.config.from_file()
    # Use OCI config as dot notation
    oci_config = Namespace(**config)

    # Pull the vaults and secrets from OCI
    kms_vault_client = oci.key_management.KmsVaultClient(config)
    kms_secret_client = oci.vault.VaultsClient(config)
    vault_list = kms_vault_client.list_vaults(compartment_id=oci_config.tenancy).data
    secrets_list = kms_secret_client.list_secrets(compartment_id=oci_config.tenancy).data
    logging.debug(f"Vault list: {vault_list}")
    logging.debug(f"Secrets list: {secrets_list}")
    
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

                try:
                    if not [r for r in tf.tfstate.resources if r['module'] == module_path and r['type'] == vault_type]:
                        logging.info(f"Importing {vault_resource_path} into Terraform state")
                        tf.import_cmd(vault_resource_path, vault.id)
                    else:
                        logging.info(f"{vault_resource_path} already exists in Terraform state")
                except AttributeError:
                    logging.info(f"Importing {vault_resource_path} into Terraform state")
                    tf.import_cmd(vault_resource_path, vault.id)
    
            # if the vault is pending deletion, activate it and import it into the terraform state
            if vault.lifecycle_state == oci.key_management.models.Vault.LIFECYCLE_STATE_PENDING_DELETION:
                logging.info(f"Vault {vault.id} is PENDING DELETION, changing to ACTIVE")
                kms_vault_client.cancel_vault_deletion(vault_id=vault.id)

                try:
                    if not [r for r in tf.tfstate.resources if r['module'] == module_path and r['type'] == vault_type]:
                        logging.info(f"Importing {vault_resource_path} into Terraform state")
                        tf.import_cmd(vault_resource_path, vault.id)
                    else:
                        logging.info(f"{vault_resource_path} already exists in Terraform state")
                except AttributeError:
                    logging.info(f"Importing {vault_resource_path} into Terraform state")
                    tf.import_cmd(vault_resource_path, vault.id)
    
            # if the key exists, import it into the terraform state
            for key in keys_list:
                logging.debug(f"Looping through key OCID: {key.id}")
                
                if key.display_name == sinput.key_name:
                    logging.debug(f"Found a match on key name: {key.display_name}")
                    key_resource_path = '.'.join([module_path, key_type, key_id])
                    key_endpoint_path = '/'.join(['managementEndpoint', vault.management_endpoint, 'keys', key.id])

                    try:
                        if not [r for r in tf.tfstate.resources if r['module'] == module_path and r['type'] == key_type]:
                            logging.info(f"Importing {key_resource_path} into Terraform state")
                            tf.import_cmd(key_resource_path, key_endpoint_path)
                        else:
                            logging.info(f"{key_resource_path} already exists in Terraform state")
                    except AttributeError:
                        logging.info(f"Importing {key_resource_path} into Terraform state")
                        tf.import_cmd(key_resource_path, key_endpoint_path)
                    break
    
            # check for existing secrets, if it exists, import it into the terraform state
            for secret in secrets_list:
                logging.debug(f"Looping through secret OCID: {secret.id}")

                if secret.vault_id == vault.id and secret.secret_name == sinput.secret_name:
                    logging.debug(f"Found a match on secret name: {secret.secret_name}")
                    secret_resource_path = '.'.join([module_path, secret_type, secret_id])

                    try:
                        if not [r for r in tf.tfstate.resources if r['module'] == module_path and r['type'] == secret_type]:
                            logging.info(f"Importing {secret_resource_path} into Terraform state")
                            tf.import_cmd(secret_resource_path, secret.id)
                        else:
                            logging.info(f"{secret_resource_path} already exists in Terraform state")
                    except AttributeError:
                        logging.info(f"Importing {secret_resource_path} into Terraform state")
                        tf.import_cmd(secret_resource_path, secret.id)
                    break
            break

        
if __name__ == "__main__":
    main()