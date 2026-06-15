terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# DATA SOURCE: apenas LÊ um arquivo existente (não cria nada).
data "local_file" "entrada" {
  filename = "${path.module}/entrada.txt"
}

# Gera uma senha. ATENÇÃO: ela será gravada em TEXTO PLANO no state.
resource "random_password" "senha" {
  length  = 16
  special = true
}

# Materializa um arquivo usando o dado lido + a senha (demo).
resource "local_file" "relatorio" {
  filename = "${path.module}/relatorio.txt"
  content  = "entrada lida: ${data.local_file.entrada.content}\n"
}

output "conteudo_lido" {
  value = data.local_file.entrada.content
}

# sensitive oculta no CLI, mas o valor existe em texto plano no state.
output "segredo" {
  value     = random_password.senha.result
  sensitive = true
}
