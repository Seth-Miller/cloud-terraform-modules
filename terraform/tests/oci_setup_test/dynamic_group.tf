resource "oci_identity_dynamic_group" "id" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}_dynamic_group"
  description    = "${var.project_name}_dynamic_group"
  matching_rule  = "Any {instance.id = ${oci_core_instance.vm.id}}"

  freeform_tags = {
    Name    = "${var.project_name}_dynamic_group"
    Project = var.project_name
  }
}

resource "oci_identity_policy" "id" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}_policy"
  description    = "${var.project_name}_policy"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.id.name} to manage all-resources IN TENANCY",
    "Allow dynamic-group ${oci_identity_dynamic_group.id.name} to read secret-family in compartment ${var.project_name}_compartment",
  ]

  freeform_tags = {
    Name    = "${var.project_name}_policy"
    Project = var.project_name
  }
}