module "oci_load_git_secret" {
  source = "../../modules/oci_load_git_secret"

  project_name = var.project_name
  region       = var.region
  compartment  = var.root_compartment_ocid
  git_secret   = local.git_secret
}