# Etapa 02 — Variáveis, outputs e tipos ⭐

## Objetivo
Parametrizar a configuração com **input variables**, expor resultados com **outputs**, e dominar a **precedência de variáveis** (tema campeão de erros na prova).

## Conceito direto

**Input variables** (`variable`) = os "parâmetros de entrada" do seu código. Tornam o módulo reutilizável.

```hcl
variable "ambiente" {
  description = "Nome do ambiente"
  type        = string
  default     = "dev"
}
```
Referência: `var.ambiente`.

**Tipos** (a prova pergunta):
- Primitivos: `string`, `number`, `bool`.
- Coleções: `list(...)`, `set(...)`, `map(...)`.
- Estruturais: `object({...})`, `tuple([...])`.
- `any` (qualquer tipo).

**Outputs** (`output`) = valores expostos após o `apply` (e consumidos por outros módulos).
```hcl
output "caminho_arquivo" {
  value = local_file.config.filename
}
```

### Precedência de variáveis (DECORE — do MENOR para o MAIOR poder de sobrescrita)
1. `default` no bloco `variable` (mais fraco)
2. Variáveis de ambiente `TF_VAR_nome`
3. Arquivo `terraform.tfvars`
4. Arquivo `*.auto.tfvars` (em ordem alfabética)
5. Flags `-var` e `-var-file` na linha de comando (mais forte — **vence todos**)

> Regra mental: **quanto mais perto da linha de comando, mais forte.** O que você digita na hora ganha do que está em arquivo, que ganha do ambiente, que ganha do default.

**Variáveis sensíveis:** `sensitive = true` esconde o valor da saída de `plan`/`apply`. (Atenção: ainda fica em texto plano no state — assunto da etapa 10.)

## Mentalidade de programador
- `variable` = argumentos de função com valor padrão.
- `output` = `return` da função.
- `var.x` = ler o argumento; `local.x` (etapa 05) = constante interna.
- Precedência = igual a config em apps: flag CLI > arquivo de config > env var > default no código.

## Lab

Arquivos nesta pasta geram um arquivo de configuração parametrizado.

### Passo 1 — o código
`variables.tf`, `main.tf`, `outputs.tf` e `terraform.tfvars` já estão criados. Leia-os.

### Passo 2 — execute
```bash
cd labs/02-variaveis-outputs
terraform init
terraform apply -auto-approve
cat app.conf            # veja os valores aplicados
terraform output        # veja todos os outputs
terraform output url    # veja um output específico
```

### Passo 3 — teste a precedência (o experimento mais importante desta etapa)
O `default` de `ambiente` é `dev`. O `terraform.tfvars` define `prod`. Veja quem ganha:
```bash
terraform apply -auto-approve
grep ambiente app.conf          # prod (tfvars venceu o default)

# Agora a env var:
TF_VAR_ambiente=staging terraform apply -auto-approve
grep ambiente app.conf          # ainda prod! tfvars > env var

# Agora a flag -var (a mais forte):
terraform apply -auto-approve -var="ambiente=hotfix"
grep ambiente app.conf          # hotfix! -var vence todos
```

### Passo 4 — variável sem default (obrigatória)
A variável `responsavel` não tem default. Se você remover do `tfvars`, o Terraform **pergunta interativamente** no `apply`. Teste comentando a linha no `terraform.tfvars` e rodando `terraform plan`.

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- **Sabar a ordem de precedência de cor.** `-var` na CLI sempre vence. `*.auto.tfvars` é carregado automaticamente; `terraform.tfvars` também; outros `.tfvars` precisam de `-var-file`.
- Variável **sem `default` e sem valor** → Terraform pede interativamente (ou falha em modo `-input=false`).
- `sensitive = true` **não criptografa o state**; só oculta da saída do CLI.
- Tipos: `list` é ordenada e aceita duplicatas; `set` não tem ordem e não aceita duplicatas; `map` é chave→valor.
- `TF_VAR_nome` é o formato exato da variável de ambiente.

## Mini-desafio
1. Adicione uma variável `portas` do tipo `list(number)` e use no `app.conf`.
2. Crie um `producao.auto.tfvars` e veja-o ser carregado automaticamente (sem `-var-file`).
3. Marque `responsavel` como `sensitive = true` e veja a diferença no `apply`.

## Checklist
- [ ] Sei declarar variáveis com `type`, `default`, `description`.
- [ ] Sei a precedência de variáveis na ordem correta.
- [ ] Sei a diferença entre `terraform.tfvars`, `*.auto.tfvars` e `-var-file`.
- [ ] Sei o que faz `sensitive = true` (e o que NÃO faz).
- [ ] Sei usar `terraform output`.
