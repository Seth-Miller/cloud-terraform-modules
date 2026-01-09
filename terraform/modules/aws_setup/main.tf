data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/scripts/init.tpl", {})
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/scripts/git_credential_helper.tpl", { secret_name = var.secret_name, region = var.region })
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

output "template_cloudinit_config" {
  value = data.template_cloudinit_config.config.rendered
}
