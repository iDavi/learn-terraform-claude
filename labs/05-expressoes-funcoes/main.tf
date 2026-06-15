terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  # Constante computada (DRY)
  prefixo = "${var.ambiente}-app"

  # Ternário: prod tem 3 réplicas, demais ambientes têm 1
  replicas = var.ambiente == "prod" ? 3 : 1

  # for expression -> lista em maiúsculas
  servicos_upper = [for s in var.servicos : upper(s)]

  # for expression -> mapa nome => comprimento
  tamanho_nomes = { for s in var.servicos : s => length(s) }

  # merge de tags comuns com específicas
  tags = merge(
    { gerenciado_por = "terraform" },
    { ambiente = var.ambiente }
  )
}

resource "local_file" "resultado" {
  filename = "${path.module}/resultado.json"
  content = jsonencode({
    prefixo        = local.prefixo
    replicas       = local.replicas
    servicos_upper = local.servicos_upper
    tamanho_nomes  = local.tamanho_nomes
    tags           = local.tags
    settings       = var.settings
  })
}
