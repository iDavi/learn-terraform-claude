variable "nome" {
  description = "Nome do serviço"
  type        = string
}

variable "porta" {
  description = "Porta do serviço"
  type        = number
  default     = 8080
}

variable "ambiente" {
  description = "Ambiente alvo"
  type        = string
}
