terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# null_resource: recurso "vazio" útil para hospedar provisioners.
resource "null_resource" "tarefa" {
  # Muda o triggers para forçar recriação quando quiser.
  triggers = {
    sempre = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'provisioner rodou em ${timestamp()}' >> ${path.module}/provisioner.log"
  }
}

# Recurso para o lab de IMPORT (Passo 4). Descomente quando chegar lá.
# resource "local_file" "existente" {
#   filename = "${path.module}/manual.txt"
#   content  = "criado fora do terraform\n"
# }
