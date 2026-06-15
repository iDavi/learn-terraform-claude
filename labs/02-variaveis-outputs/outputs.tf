output "caminho_arquivo" {
  description = "Onde o arquivo de config foi gerado"
  value       = local_file.config.filename
}

output "url" {
  description = "URL montada a partir das variáveis"
  value       = "http://localhost:${var.porta}/${var.ambiente}"
}

output "resumo" {
  description = "Resumo do ambiente"
  value = {
    ambiente    = var.ambiente
    porta       = var.porta
    responsavel = var.responsavel
  }
}
