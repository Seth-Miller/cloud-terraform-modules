resource "oci_identity_dynamic_group" "id" {
  compartment_id = local.parent_compartment_ocid
  name           = local.dynamic_group_name
  description    = local.dynamic_group_description
  matching_rule  = "Any {${join(",", [for vm in oci_core_instance.vm : "instance.id = '${vm.id}'"])}}"
}

resource "oci_identity_policy" "id" {
  compartment_id = local.parent_compartment_ocid
  name           = local.policy_name
  description    = local.policy_description
  statements     = [
    "Allow dynamic-group ${oci_identity_dynamic_group.id.name} to manage all-resources IN TENANCY",
    "Allow dynamic-group ${oci_identity_dynamic_group.id.name} to read secret-family in compartment ${local.compartment_name} where target.secret.id = '${oci_vault_secret.id.id}'",
  ]
}
