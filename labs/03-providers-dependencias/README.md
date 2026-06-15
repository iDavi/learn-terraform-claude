# Etapa 03 — Providers, versionamento e dependências ⭐⭐

## Objetivo
Entender **providers** (o que são, como configurar e versionar), a diferença entre `required_version` e `version` do provider, e como o Terraform resolve **dependências implícitas e explícitas** entre recursos.

## Conceito direto

**Provider** = o plugin que sabe falar com uma API (AWS, Azure, Docker, `local`, `random`...). Sem provider, o Terraform não cria nada. Cada `resource` pertence a um provider.

```hcl
terraform {
  required_version = ">= 1.3"          # versão do BINÁRIO terraform

  required_providers {
    random = {
      source  = "hashicorp/random"     # endereço no Registry: namespace/tipo
      version = "~> 3.5"               # versão do PROVIDER
    }
  }
}

provider "random" {}                    # configuração do provider
```

Não confunda:
- `required_version` → versão do **Terraform** (o binário).
- `version` dentro de `required_providers` → versão do **provider**.

### Operadores de versão (a prova cobra)
| Operador | Significado | Exemplo `~> 3.5` permite |
|---|---|---|
| `= 3.5.0` | exatamente | 3.5.0 |
| `>= 3.5` | igual ou maior | 3.5, 4.0, ... |
| `<= 3.5` | igual ou menor | ... 3.5 |
| `~> 3.5` | "pessimista": permite a última parte subir | 3.5, 3.6, 3.99 — **não** 4.0 |
| `~> 3.5.0` | permite só o patch subir | 3.5.0 a 3.5.x — **não** 3.6.0 |
| `!= 3.5.0` | exclui | tudo menos 3.5.0 |

**Lock file:** `terraform init` gera o `.terraform.lock.hcl`. Ele **trava as versões e hashes** dos providers para builds reprodutíveis. **Deve ser commitado** no Git.

### Dependências
- **Implícita (preferida):** quando o recurso A referencia um atributo do recurso B (`b.id`), o Terraform cria B antes de A automaticamente. Ele monta um grafo de dependências.
- **Explícita:** `depends_on = [recurso.b]` quando não há referência direta mas a ordem importa.

Veja o grafo: `terraform graph`.

## Mentalidade de programador
- Provider = uma biblioteca/SDK que você importa.
- `required_providers` = seu `package.json` / `requirements.txt` com pinning de versão.
- `.terraform.lock.hcl` = `package-lock.json` / `poetry.lock`.
- Dependência implícita = o Terraform faz "tree-shaking"/ordenação topológica olhando quem usa o output de quem.

## Lab

Esta pasta usa dois providers (`random` e `local`) e demonstra os dois tipos de dependência.

### Passo 1 — o código
`main.tf`:
```hcl
resource "random_pet" "nome" {        # gera um nome aleatório, ex: "calm-tiger"
  length = 2
}

resource "random_integer" "porta" {
  min = 8000
  max = 9000
}

# Dependência IMPLÍCITA: este recurso usa atributos dos de cima,
# então o Terraform cria os random_* primeiro.
resource "local_file" "servico" {
  filename = "${path.module}/servico-${random_pet.nome.id}.conf"
  content  = "nome=${random_pet.nome.id}\nporta=${random_integer.porta.result}\n"
}

# Dependência EXPLÍCITA: não referencia o local_file, mas queremos
# que rode depois dele.
resource "local_file" "log" {
  filename   = "${path.module}/deploy.log"
  content    = "deploy concluido\n"
  depends_on = [local_file.servico]
}
```

### Passo 2 — execute e observe a ordem
```bash
cd labs/03-providers-dependencias
terraform init
ls -la .terraform.lock.hcl     # o lock file foi criado
terraform apply -auto-approve
ls *.conf deploy.log           # tudo criado na ordem certa
```

### Passo 3 — veja o grafo de dependências
```bash
terraform graph                # saída em formato DOT
# Se tiver graphviz: terraform graph | dot -Tpng > grafo.png
```

### Passo 4 — experimento de versão
Edite `version = "~> 3.5"` para `version = "= 3.1.0"` em `main.tf` e rode:
```bash
terraform init -upgrade        # observe o Terraform resolver outra versão
cat .terraform.lock.hcl        # a versão travada mudou
```

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- `~> 3.5` permite `3.x` mas **bloqueia 4.0** (mudança de major). Saiba prever isto.
- `.terraform.lock.hcl` **deve ir para o controle de versão**; `.terraform/` (a pasta) **não** (é cache local, igual `node_modules`).
- `terraform init -upgrade` é o que atualiza providers respeitando as constraints.
- Dependência **implícita** (por referência) é preferível a `depends_on`.
- `terraform graph` mostra o grafo de dependências.
- Você pode ter **múltiplas configurações do mesmo provider** com `alias` (ex.: duas regiões AWS).
- Provider source `hashicorp/local` = `registry.terraform.io/hashicorp/local` (o prefixo do registry oficial é implícito).

## Mini-desafio
1. Adicione `provider "random"` com um `alias` e use-o num recurso (`provider = random.outro`).
2. Crie um `depends_on` desnecessário e veja no `plan` que a ordem não muda — entenda por que dependência implícita já bastava.

## Checklist
- [ ] Diferencio `required_version` de `version` do provider.
- [ ] Sei prever o que `~>` permite.
- [ ] Sei o que é e para que serve o `.terraform.lock.hcl` (e que vai pro Git).
- [ ] Entendo dependência implícita vs `depends_on`.
- [ ] Sei que `.terraform/` não vai pro Git.
