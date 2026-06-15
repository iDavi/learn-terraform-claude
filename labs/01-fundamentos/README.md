# Etapa 01 — Fundamentos e o workflow core ⭐

## Objetivo
Entender o que é Infraestrutura como Código (IaC), por que o Terraform existe, e executar o ciclo completo `init → plan → apply → destroy` criando um recurso real na sua máquina.

## Conceito direto

**IaC** = descrever a infraestrutura em arquivos de texto versionáveis, em vez de clicar em consoles. Vantagens que a prova cobra:
- **Versionável** (Git): histórico, revisão, rollback.
- **Reprodutível / consistente**: o mesmo código gera o mesmo ambiente.
- **Automação** e colaboração.

**Por que Terraform e não scripts (bash/Ansible)?**
- Terraform é **declarativo**: você diz *o estado final desejado*, ele calcula os passos. Scripts são *imperativos* (você diz os passos).
- Terraform é **cloud-agnostic**: um workflow, +1000 providers.
- Terraform mantém **state** para saber o que já existe (próxima etapa que você vai amar/odiar).
- **Imutável vs mutável**: Terraform tende a substituir recursos em vez de alterá-los no lugar.

**Linguagem:** HCL (HashiCorp Configuration Language). Arquivos `.tf`. O Terraform lê *todos* os `.tf` da pasta e os concatena — a ordem dos arquivos e dos blocos não importa (ele resolve dependências sozinho).

### O workflow core (decore isto)
| Comando | O que faz |
|---|---|
| `terraform init` | Baixa os providers e inicializa o backend. Roda **uma vez** por projeto (ou quando muda provider/backend). |
| `terraform plan` | Mostra o que será criado/alterado/destruído. **Não muda nada.** É um dry-run. |
| `terraform apply` | Aplica as mudanças. Pede confirmação (`yes`) ou use `-auto-approve`. |
| `terraform destroy` | Remove tudo que o Terraform criou. |

Comandos auxiliares já úteis: `terraform fmt` (formata), `terraform validate` (valida sintaxe), `terraform show` (mostra o state legível).

## Mentalidade de programador
- `init` = `npm install` / `pip install -r` (baixa dependências).
- `plan` = `git diff` antes de commitar.
- `apply` = aplicar o diff.
- O **state** = um banco de dados que o Terraform usa para lembrar o que já criou. Sem ele, o Terraform não sabe a diferença entre "criar" e "atualizar".

## Lab

Os arquivos já estão nesta pasta. Eles criam um arquivo de texto no disco usando o provider `local` (zero custo, zero nuvem).

### Passo 1 — leia o código
`main.tf`:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "local" {}

resource "local_file" "hello" {
  filename = "${path.module}/saida.txt"
  content  = "Meu primeiro recurso gerenciado por Terraform.\n"
}
```

Anatomia de um bloco `resource`:
```
resource  "local_file"   "hello"   { ... }
   |           |            |
 tipo      tipo do      nome local (interno ao TF)
 bloco     recurso      → referência: local_file.hello
```

### Passo 2 — execute o workflow
```bash
cd labs/01-fundamentos

terraform init      # baixa o provider hashicorp/local
terraform plan      # leia: "Plan: 1 to add, 0 to change, 0 to destroy."
terraform apply     # digite: yes
cat saida.txt       # o arquivo foi criado!

terraform show      # veja o recurso no state
```

### Passo 3 — observe a idempotência
```bash
terraform apply     # leia: "No changes. Your infrastructure matches the configuration."
```
Rodar de novo **não recria nada** — esse é o coração do declarativo.

### Passo 4 — provoque uma mudança
Edite `content` em `main.tf` (mude o texto), depois:
```bash
terraform plan      # "1 to change" — note o "~" (update) ou "-/+" (replace)
terraform apply
```

### Passo 5 — limpe
```bash
terraform destroy   # digite: yes — o arquivo some
```

## Armadilhas da prova
- `terraform plan` **nunca** altera infraestrutura. (Pegadinha clássica.)
- `init` é necessário antes de `plan`/`apply` e ao trocar de provider/backend.
- Terraform é **declarativo**, não imperativo.
- O Terraform lê **todos** os `.tf` da pasta — separar em vários arquivos é só organização, não muda o comportamento.
- `apply` por padrão **pede confirmação**; `-auto-approve` pula isso (cuidado em produção).
- Sem mudanças no código → `apply` não faz nada (idempotência).

## Mini-desafio
1. Adicione um segundo `resource "local_file"` que cria `notas.txt` com outro conteúdo. Rode `plan` e confirme "2 to add" (na verdade "1 to add" se o primeiro já existir). 
2. Rode `terraform fmt` e veja se o arquivo é reformatado.

## Checklist
- [ ] Sei explicar IaC e 3 vantagens.
- [ ] Sei a diferença entre declarativo e imperativo.
- [ ] Rodei init/plan/apply/destroy e entendi a saída de cada um.
- [ ] Entendi o que é idempotência na prática.
- [ ] Sei que `plan` não altera nada.
