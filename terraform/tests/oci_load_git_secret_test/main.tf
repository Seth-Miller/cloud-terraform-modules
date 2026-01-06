data "external" "getvault" {
  program = ["python", "${path.module}/getvault.py"]

  query = {
    vault_name = "${var.project_name}_git-secret"
    secret_name = "${var.project_name}_git-secret"
    key_name = "${var.project_name}_git-secret"
    working_dir = abspath("${path.root}")
  }
}

module "oci_load_git_secret" {
  source = "../../modules/oci_load_git_secret"

  project_name = var.project_name
  region       = var.region
  compartment  = var.root_compartment_ocid
  git_secret   = local.git_secret
}
