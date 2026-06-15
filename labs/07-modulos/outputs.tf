output "url_web" {
  value = module.web.url
}

output "url_api" {
  value = module.api.url
}

output "todos_arquivos" {
  value = [module.web.arquivo, module.api.arquivo]
}
