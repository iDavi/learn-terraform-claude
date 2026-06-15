variable "nomes_count" {
  description = "Lista usada com count (sensível a remoção do meio)"
  type        = list(string)
  default     = ["inicio", "meio", "fim"]
}

variable "nomes_foreach" {
  description = "Conjunto usado com for_each (estável)"
  type        = set(string)
  default     = ["api", "web", "worker"]
}

variable "criar_extra" {
  description = "Liga/desliga um recurso opcional"
  type        = bool
  default     = false
}
