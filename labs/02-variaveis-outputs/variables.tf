variable "ambiente" {
  description = "Nome do ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "porta" {
  description = "Porta da aplicação"
  type        = number
  default     = 8080
}

variable "debug" {
  description = "Liga modo debug"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags chave-valor"
  type        = map(string)
  default = {
    time    = "plataforma"
    projeto = "estudo-terraform"
  }
}

# Sem default: vira variável obrigatória.
variable "responsavel" {
  description = "Pessoa responsável pelo ambiente"
  type        = string
}
