resource "oci_identity_compartment" "compartment" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}_compartment"
  description    = "${var.project_name}_compartment"

  freeform_tags = {
    Name    = "${var.project_name}_compartment"
    Project = var.project_name
  }
}