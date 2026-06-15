terraform {
  required_version = ">= 1.3"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "random" {}
provider "local" {}

resource "random_pet" "nome" {
  length = 2
}

resource "random_integer" "porta" {
  min = 8000
  max = 9000
}

# Dependência IMPLÍCITA: usa atributos dos recursos random_*,
# então o Terraform os cria primeiro (grafo de dependências).
resource "local_file" "servico" {
  filename = "${path.module}/servico-${random_pet.nome.id}.conf"
  content  = "nome=${random_pet.nome.id}\nporta=${random_integer.porta.result}\n"
}

# Dependência EXPLÍCITA: não há referência, mas forçamos a ordem.
resource "local_file" "log" {
  filename   = "${path.module}/deploy.log"
  content    = "deploy concluido\n"
  depends_on = [local_file.servico]
}
