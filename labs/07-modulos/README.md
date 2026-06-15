# Etapa 07 — Módulos: criar e consumir ⭐⭐⭐

## Objetivo
Entender o que é um **módulo**, criar um módulo local reutilizável, consumi-lo passando **inputs** e lendo **outputs**, e conhecer as fontes (`source`) e o versionamento de módulos do Registry.

## Conceito direto

**Módulo** = um conjunto de arquivos `.tf` numa pasta. **Todo diretório Terraform já é um módulo** (o "root module"). Quando um módulo chama outro, o chamado é um **child module**.

```hcl
module "servico_web" {
  source = "./modules/servico"   # de onde vem o módulo

  # inputs (variáveis do módulo)
  nome     = "web"
  porta    = 8080
  ambiente = var.ambiente
}

# usar um output do módulo:
# module.servico_web.url
```

### Fontes de módulo (`source`) — a prova cobra muito
| Tipo | Exemplo |
|---|---|
| Local | `./modules/servico` ou `../shared` |
| Terraform Registry | `terraform-aws-modules/vpc/aws` |
| GitHub | `github.com/org/repo` ou `git::https://...` |
| Git genérico | `git::https://example.com/repo.git//subdir?ref=v1.2.0` |
| HTTP/arquivo | URL para um `.zip` |
| Bucket | `s3::...`, `gcs::...` |

**Versionamento:** o argumento `version` **só funciona com módulos do Registry** (e do Terraform Cloud). Para Git, você fixa a versão com `?ref=v1.2.0` na URL.
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}
```

### Inputs e outputs
- O módulo declara `variable` (seus inputs) e `output` (o que devolve).
- O chamador passa valores e lê `module.<nome>.<output>`.
- Variável de módulo **sem default** é obrigatória.

> `terraform init` baixa/instala os módulos (assim como providers). Mudou o `source`? Rode `init` de novo.

## Mentalidade de programador
- Módulo = **função** ou **pacote/classe**: tem parâmetros (inputs), corpo (recursos) e retorno (outputs).
- `source` = o `import`/`require` apontando para um pacote (local, npm, git).
- `version` = pinning de dependência (só funciona em "registries", como npm; Git você fixa por tag/commit).
- Encapsulamento: quem usa o módulo não precisa saber dos recursos internos, só da interface (inputs/outputs).

## Lab

Estrutura desta pasta:
```
07-modulos/
├── main.tf            # root module: chama o child module 2x
├── outputs.tf
└── modules/
    └── servico/       # child module reutilizável
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Passo 1 — leia o módulo filho
`modules/servico/` recebe `nome`, `porta`, `ambiente` e gera um arquivo de config, devolvendo `url` e `arquivo`.

### Passo 2 — veja o root chamando o módulo duas vezes
`main.tf` instancia `servico` para "web" e "api" — reutilização real, sem copiar código.

### Passo 3 — execute
```bash
cd labs/07-modulos
terraform init        # observe "Initializing modules..."
terraform apply -auto-approve
ls modules/servico/*.conf 2>/dev/null; ls *.conf 2>/dev/null
terraform output      # outputs montados a partir dos outputs do módulo
```

### Passo 4 — inspecione no state
```bash
terraform state list  # repare no prefixo "module.web." e "module.api."
```
Recursos dentro de módulos aparecem como `module.<nome>.<tipo>.<recurso>`.

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- **Todo diretório é um módulo** (o root). Não existe "projeto sem módulo".
- `version` no bloco `module` **só vale para Registry/TFC**, não para `source` local nem Git. Para Git use `?ref=`.
- Mudou `source` ou adicionou módulo → precisa de `terraform init`.
- Recursos de módulo no state têm prefixo `module.<nome>.`.
- Para passar dados de um módulo para outro: use o **output** de um como **input** do outro (no root).
- Providers normalmente são **herdados** pelo módulo filho; passar provider explícito usa o argumento `providers = {}`.
- O `source` de Registry tem o formato `<NAMESPACE>/<NAME>/<PROVIDER>` (3 partes).

## Mini-desafio
1. Adicione uma terceira instância do módulo (`worker`) só mudando o bloco `module`.
2. Adicione um novo output ao módulo filho e consuma-o no root.
3. Pesquise no [Terraform Registry](https://registry.terraform.io/) um módulo e identifique seu `source` e `version`.

## Checklist
- [ ] Sei que root e child são ambos módulos.
- [ ] Sei passar inputs e ler outputs (`module.x.output`).
- [ ] Conheço os tipos de `source` (local, registry, git).
- [ ] Sei que `version` só vale para Registry/TFC.
- [ ] Reconheço recursos de módulo no state pelo prefixo `module.`.
