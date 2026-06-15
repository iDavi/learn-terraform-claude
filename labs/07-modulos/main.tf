terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "ambiente" {
  type    = string
  default = "dev"
}

# Mesma "função" (módulo) chamada duas vezes com argumentos diferentes.
module "web" {
  source   = "./modules/servico"
  nome     = "web"
  porta    = 8080
  ambiente = var.ambiente
}

module "api" {
  source   = "./modules/servico"
  nome     = "api"
  porta    = 9090
  ambiente = var.ambiente
}
