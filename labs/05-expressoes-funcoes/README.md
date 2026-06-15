# Etapa 05 — Expressões, funções, locals e condicionais ⭐⭐⭐

## Objetivo
Transformar dados dentro do Terraform: **locals**, **funções built-in**, **condicionais** (`? :`), **for expressions**, **dynamic blocks** e o `terraform console`.

## Conceito direto

**Locals** (`locals`) = valores nomeados computados uma vez e reutilizados. Diferente de `variable`: não recebe valor de fora, é interno.
```hcl
locals {
  prefixo = "${var.ambiente}-app"
  comum   = { gerenciado_por = "terraform" }
}
# uso: local.prefixo
```

**Funções built-in** (o Terraform NÃO permite definir funções próprias — pegadinha de prova). Categorias e exemplos:
- String: `upper`, `lower`, `format`, `join`, `split`, `replace`, `trimspace`, `substr`.
- Numéricas: `max`, `min`, `abs`, `ceil`, `floor`.
- Coleções: `length`, `concat`, `merge`, `keys`, `values`, `lookup`, `contains`, `element`, `flatten`, `distinct`, `toset`, `sort`.
- Encoding: `jsonencode`, `jsondecode`, `base64encode`, `yamlencode`.
- Data/hash: `timestamp`, `formatdate`, `uuid`, `filemd5`.
- Filesystem: `file`, `templatefile`, `fileexists`.
- Tipo/conversão: `tostring`, `tonumber`, `tolist`, `tomap`, `try`, `can`, `coalesce`.

**Condicional ternário:** `condicao ? valor_se_true : valor_se_false`.

**For expression:** transforma coleções.
```hcl
[for s in var.lista : upper(s)]                  # gera lista
{for k, v in var.mapa : k => upper(v)}           # gera mapa
[for s in var.lista : s if length(s) > 3]        # com filtro
```

**Splat:** `aws_instance.web[*].id` = lista de todos os ids.

**Dynamic block:** gera blocos repetidos dinamicamente (ex.: várias `ingress` rules).
```hcl
dynamic "setting" {
  for_each = var.settings
  content {
    name  = setting.key
    value = setting.value
  }
}
```

## Mentalidade de programador
- `locals` = `const` no topo do arquivo (DRY).
- Funções built-in = stdlib; você não escreve as suas (sem user-defined functions).
- For expression = list/dict comprehension de Python ou `.map()/.filter()` de JS.
- `terraform console` = um REPL para testar expressões. Use-o sem parar.
- `try()` = try/except curto; `can()` = retorna bool se a expressão é válida.

## Lab

### Passo 1 — o REPL (sua nova melhor ferramenta)
```bash
cd labs/05-expressoes-funcoes
terraform init

terraform console
```
Dentro do console, teste:
```hcl
> upper("terraform")
> join("-", ["a", "b", "c"])
> [for n in [1,2,3,4] : n * n]
> {for k, v in {a=1, b=2} : k => v * 10}
> length(["x","y","z"])
> merge({a=1}, {b=2})
> contains(["dev","prod"], "prod")
> var.ambiente == "prod" ? 3 : 1
> lookup({dev=1, prod=3}, "prod", 0)
```
Saia com `exit`.

### Passo 2 — aplique e leia a saída gerada
```bash
terraform apply -auto-approve
cat resultado.json        # JSON gerado a partir de locals, for e funções
terraform output
```

### Passo 3 — entenda o `main.tf`
Ele usa `locals`, ternário (réplicas por ambiente), `for` (transformar lista em uppercase e mapa), `merge` de tags e `dynamic block`.

### Passo 4 — experimente
Mude `var.ambiente` para `prod` via `-var` e veja `replicas` mudar de 1 para 3:
```bash
terraform apply -auto-approve -var="ambiente=prod"
grep replicas resultado.json
```

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- **Não existem funções definidas pelo usuário** no Terraform — só built-in.
- `terraform console` é o jeito oficial de testar expressões/funções.
- `lookup(map, chave, default)` evita erro quando a chave não existe; `coalesce(a, b, c)` retorna o primeiro não-nulo/não-vazio.
- Ternário: condição **booleana**, dois ramos do **mesmo tipo**.
- `for` com `[]` gera lista/tuple; com `{}` gera objeto/mapa.
- `dynamic` blocks geram blocos aninhados repetidos; o iterador padrão tem o nome do bloco (`.key`/`.value`).
- `element(list, index)` faz wrap-around (índice circular); `list[index]` não.
- `templatefile()` renderiza um template externo com variáveis.

## Mini-desafio
1. No console, gere uma lista só com nomes que tenham mais de 4 letras usando `for ... if`.
2. Use `templatefile()` para gerar um arquivo a partir de um `.tftpl`.
3. Combine `merge()` para juntar tags comuns com tags específicas do ambiente.

## Checklist
- [ ] Uso `locals` para evitar repetição.
- [ ] Sei que não existem funções definidas pelo usuário.
- [ ] Sei usar `terraform console`.
- [ ] Escrevo for expressions para lista e para mapa.
- [ ] Entendo o ternário e `lookup`/`coalesce`/`try`.
- [ ] Sei o que é um `dynamic` block.
