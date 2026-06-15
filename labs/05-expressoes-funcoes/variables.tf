variable "ambiente" {
  type    = string
  default = "dev"
}

variable "servicos" {
  type    = list(string)
  default = ["api", "worker", "scheduler"]
}

variable "settings" {
  type = map(string)
  default = {
    timeout = "30s"
    retries = "3"
  }
}
