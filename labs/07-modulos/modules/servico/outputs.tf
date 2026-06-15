output "url" {
  description = "URL do serviço"
  value       = "http://localhost:${var.porta}/${var.nome}"
}

output "arquivo" {
  description = "Caminho do arquivo de config gerado"
  value       = local_file.config.filename
}
