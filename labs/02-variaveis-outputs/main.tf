terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "config" {
  filename = "${path.module}/app.conf"
  content  = <<-EOT
    ambiente=${var.ambiente}
    porta=${var.porta}
    debug=${var.debug}
    responsavel=${var.responsavel}
    tags=${jsonencode(var.tags)}
  EOT
}
