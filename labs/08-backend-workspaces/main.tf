terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  # Backend padrão é "local". Veja backend-remoto-exemplo.tf.txt para o remoto.
}

# terraform.workspace devolve o nome do workspace atual.
resource "local_file" "ambiente" {
  filename = "${path.module}/ambiente.txt"
  content  = "workspace atual: ${terraform.workspace}\n"
}

output "workspace" {
  value = terraform.workspace
}
