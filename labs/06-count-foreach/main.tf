terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# count: indexado por número [0], [1], [2]
resource "local_file" "numerado" {
  count    = length(var.nomes_count)
  filename = "${path.module}/count-${count.index}-${var.nomes_count[count.index]}.txt"
  content  = "indice ${count.index} = ${var.nomes_count[count.index]}\n"
}

# for_each: indexado por chave string ["api"], ["web"]...
resource "local_file" "por_chave" {
  for_each = var.nomes_foreach
  filename = "${path.module}/foreach-${each.key}.txt"
  content  = "servico ${each.key}\n"
}

# Recurso condicional (toggle) com count
resource "local_file" "extra" {
  count    = var.criar_extra ? 1 : 0
  filename = "${path.module}/extra.txt"
  content  = "recurso opcional ativado\n"
}

output "arquivos_numerados" {
  # splat: lista de todos os filenames do recurso com count
  value = local_file.numerado[*].filename
}
