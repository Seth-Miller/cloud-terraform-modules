
eval "$(jq -r '@sh "root_compartment_ocid=\(.root_compartment_ocid) vault_name=\(.vault_name)"')"
vault_ocid=$(oci kms management vault list --all --compartment-id=$root_compartment_ocid | jq 'first(.data[] | select(."lifecycle-state" == "ACTIVE" and ."display-name" == "'$vault_name'")) | .id')
jq -n '{"vault_ocid": '$vault_ocid'}'