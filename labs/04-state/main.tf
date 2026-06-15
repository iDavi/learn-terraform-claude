terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "alpha" {
  filename = "${path.module}/alpha.txt"
  content  = "recurso alpha\n"
}

resource "local_file" "beta" {
  filename = "${path.module}/beta.txt"
  content  = "recurso beta\n"
}
