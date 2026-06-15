terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "local" {}

# Recurso 1: seu primeiro recurso gerenciado por Terraform.
# Referência interna: local_file.hello
resource "local_file" "hello" {
  filename = "${path.module}/saida.txt"
  content  = "Meu primeiro recurso gerenciado por Terraform.\n"
}

# Mini-desafio: descomente para ter um segundo recurso.
# resource "local_file" "notas" {
#   filename = "${path.module}/notas.txt"
#   content  = "Terraform lê todos os arquivos .tf da pasta.\n"
# }
