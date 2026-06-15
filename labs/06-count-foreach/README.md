# Etapa 06 — count, for_each e loops ⭐⭐⭐

## Objetivo
Criar múltiplos recursos sem copiar/colar usando **`count`** e **`for_each`**, entender quando usar cada um e como cada um endereça os recursos no state.

## Conceito direto

### `count` — repetição por número
```hcl
resource "local_file" "numerado" {
  count    = 3
  filename = "${path.module}/arquivo-${count.index}.txt"
  content  = "arquivo numero ${count.index}\n"
}
```
- Cria N recursos indexados por **inteiro**: `local_file.numerado[0]`, `[1]`, `[2]`.
- `count.index` vai de 0 a N-1.
- **Problema clássico:** se você remove um item do meio de uma lista, todos os índices seguintes "deslizam" → o Terraform destrói e recria recursos que não mudaram. Por isso `count` é melhor para recursos **idênticos** ou liga/desliga (`count = var.criar ? 1 : 0`).

### `for_each` — repetição por chave
```hcl
resource "local_file" "por_chave" {
  for_each = toset(["api", "web", "worker"])
  filename = "${path.module}/${each.key}.txt"
  content  = "servico ${each.key}\n"
}
```
- Itera sobre um **map** ou **set of strings**.
- Endereçado por **string**: `local_file.por_chave["api"]`.
- `each.key` e `each.value` disponíveis.
- **Vantagem:** remover um item **não afeta** os outros (sem deslize de índice). É o preferido quando os recursos têm identidade própria.

### Quando usar cada um (regra de prova e prática)
- `for_each`: quando os itens têm **identidade/chave estável** (mais seguro contra recriações).
- `count`: quando os recursos são **idênticos** ou para um **toggle** condicional (`0` ou `1`).

> Você **não pode** usar `count` e `for_each` no mesmo bloco.

## Mentalidade de programador
- `count` = `for (i = 0; i < n; i++)` — índice numérico.
- `for_each` = `for (key in map)` — chave estável, como iterar um dicionário.
- O perigo do `count` é o mesmo de usar índice de array como chave de lista no React: remover do meio reordena tudo.

## Lab

### Passo 1 — count em ação
```bash
cd labs/06-count-foreach
terraform init
terraform apply -auto-approve
terraform state list        # veja os [0] [1] [2] e os ["api"] ...
ls *.txt
```

### Passo 2 — sinta o problema do `count`
Edite `variables.tf`: remova `"meio"` do meio da lista `nomes_count`. Rode:
```bash
terraform plan
```
Observe: o Terraform planeja **destruir e recriar** vários arquivos (deslize de índice), mesmo os que "não mudaram".

### Passo 3 — compare com `for_each`
Agora remova `"meio"` do `set` `nomes_foreach` e rode `terraform plan`. Observe: **só o "meio" é destruído**, os outros ficam intactos. Essa é a diferença que a prova quer que você entenda.

### Passo 4 — toggle condicional com count
A variável `criar_extra` controla um recurso opcional via `count = var.criar_extra ? 1 : 0`:
```bash
terraform apply -auto-approve -var="criar_extra=true"
ls extra.txt           # existe
terraform apply -auto-approve -var="criar_extra=false"
ls extra.txt           # sumiu
```

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- `count` indexa por **número** (`[0]`); `for_each` por **chave string** (`["api"]`).
- Remover item do meio de uma lista com `count` causa **destruição/recriação em cascata**. `for_each` evita isso.
- `for_each` só aceita **map** ou **set of strings** (não aceita list diretamente → use `toset(...)`).
- `count.index` vs `each.key`/`each.value`.
- **Não use os dois no mesmo recurso.**
- `count = condição ? 1 : 0` é o padrão para recurso condicional.
- Referenciar um recurso com `count` em outro lugar: `resource.nome[*]` (splat) devolve a lista.

## Mini-desafio
1. Converta o recurso `count` para `for_each` usando um `map` de objetos (cada chave com conteúdo diferente).
2. Use splat (`local_file.numerado[*].filename`) num output.
3. Crie um `for_each` a partir de uma `list(object)` convertida com `{ for o in lista : o.nome => o }`.

## Checklist
- [ ] Sei a diferença de endereçamento entre `count` e `for_each`.
- [ ] Entendo o problema do deslize de índice no `count`.
- [ ] Sei quando preferir `for_each`.
- [ ] Sei fazer recurso condicional com `count = ... ? 1 : 0`.
- [ ] Sei que `for_each` precisa de map/set (uso `toset`).
