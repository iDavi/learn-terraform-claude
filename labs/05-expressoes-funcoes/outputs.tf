output "replicas" {
  value = local.replicas
}

output "servicos_upper" {
  value = local.servicos_upper
}

output "primeiro_servico" {
  # element faz wrap-around no índice; aqui pega o primeiro
  value = element(var.servicos, 0)
}
