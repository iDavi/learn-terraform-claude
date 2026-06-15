terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "config" {
  filename = "${path.root}/${var.ambiente}-${var.nome}.conf"
  content  = <<-EOT
    servico=${var.nome}
    porta=${var.porta}
    ambiente=${var.ambiente}
  EOT
}
