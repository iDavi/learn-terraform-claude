# Etapa 04 — State: o coração do Terraform ⭐⭐

## Objetivo
Entender **o que é o state**, por que ele existe, o que tem dentro, e dominar os subcomandos de `terraform state` (um dos blocos mais cobrados na prova).

## Conceito direto

O **state** (`terraform.tfstate`, um JSON) é o **banco de dados** que mapeia o código (`local_file.config`) para o recurso real (o arquivo no disco / a EC2 na AWS). Sem state, o Terraform não sabe:
- o que já existe (criar vs atualizar vs destruir);
- os metadados/atributos atuais dos recursos;
- as dependências entre recursos.

**Por que não descobrir tudo na hora via API?** Performance (não precisa consultar tudo a cada plan) e para guardar dados que a API não devolve. O state é a **fonte da verdade** do Terraform.

### Fatos do state que a prova adora
- Por padrão o state é **local** (`terraform.tfstate` na pasta). Backups vão para `terraform.tfstate.backup`.
- O state pode conter **dados sensíveis em texto plano** (senhas, chaves). Por isso **nunca commite o state** e prefira backend remoto com criptografia (etapa 08/10).
- **Drift**: quando o recurso real muda fora do Terraform. `terraform plan` (que faz um *refresh*) detecta a diferença.
- `terraform refresh` (ou `terraform apply -refresh-only`) atualiza o state com a realidade, sem mudar infra.

### Subcomandos de `terraform state` (DECORE)
| Comando | O que faz |
|---|---|
| `terraform state list` | Lista os recursos no state. |
| `terraform state show <addr>` | Mostra os atributos de um recurso. |
| `terraform state mv <orig> <dest>` | Renomeia/move um recurso no state (sem destruir/recriar). |
| `terraform state rm <addr>` | Remove o recurso do state (Terraform "esquece", mas o recurso real continua existindo). |
| `terraform state pull` | Baixa e imprime o state atual (útil com backend remoto). |
| `terraform state push` | Sobe um state (perigoso, raramente usado). |
| `terraform state replace-provider` | Troca o provider de recursos no state. |

Relacionados: `terraform show` (state legível), `terraform output` (lê outputs do state), `terraform taint`/`untaint` (legado → hoje use `apply -replace`, etapa 09), `terraform import` (etapa 09).

## Mentalidade de programador
- State = um **banco de dados / ORM mapping** entre seu modelo (código) e as linhas reais (infra).
- `state mv` = renomear uma variável sem perder o objeto que ela aponta (refactor).
- `state rm` = remover do tracking do Git sem apagar o arquivo (`git rm --cached`).
- Drift = alguém editou o arquivo "à mão" fora do seu controle de versão.

## Lab

### Passo 1 — crie recursos e inspecione o state
```bash
cd labs/04-state
terraform init
terraform apply -auto-approve

terraform state list                       # liste os recursos
terraform state show local_file.alpha      # veja atributos
cat terraform.tfstate | head -40           # é só um JSON
```

### Passo 2 — provoque DRIFT (edição fora do Terraform)
```bash
echo "editado na marra" > alpha.txt        # mudamos o arquivo SEM terraform
terraform plan                             # o plan detecta o drift e quer corrigir
terraform apply -auto-approve              # volta ao estado declarado
```

### Passo 3 — refactor com `state mv`
Suponha que você renomeie o recurso `alpha` para `principal` no `main.tf`. Sem `state mv`, o Terraform destruiria `alpha` e criaria `principal`. Com ele, é só renomear:
```bash
# (edite main.tf trocando "alpha" por "principal" no nome do resource)
terraform state mv local_file.alpha local_file.principal
terraform plan      # "No changes" — nenhum recurso destruído/recriado
```

### Passo 4 — `state rm` (o Terraform "esquece")
```bash
terraform state rm local_file.beta
terraform state list        # beta sumiu do state
ls beta.txt                 # MAS o arquivo real continua lá!
terraform plan              # Terraform quer CRIAR beta de novo (não sabe que existe)
```
Para reconciliar, você usaria `terraform import` (etapa 09).

### Passo 5 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- **`state rm` NÃO apaga o recurso real** — só o remove do tracking do Terraform.
- **`state mv` NÃO destrói/recria** — é o jeito certo de renomear/mover sem downtime.
- O state pode ter **segredos em texto plano** → trate como sensível, use backend remoto com criptografia, nunca commite.
- `terraform plan` faz um **refresh** do state por padrão para detectar drift; `-refresh=false` desliga.
- O arquivo de backup é `terraform.tfstate.backup`.
- Para inspecionar de forma legível use `terraform show` ou `terraform state show`, não abra o JSON na prova mental.
- State remoto é necessário para **trabalho em equipe** (e habilita **state locking** — etapa 08).

## Mini-desafio
1. Use `terraform state show` em dois recursos e identifique o atributo `id`.
2. Faça drift deletando um dos arquivos e veja o `plan` querer recriá-lo.
3. Pesquise: por que `terraform state push` é perigoso?

## Checklist
- [ ] Sei explicar o propósito do state em uma frase.
- [ ] Sei a diferença entre `state rm` e `destroy`.
- [ ] Sei usar `state list`, `state show`, `state mv`, `state rm`.
- [ ] Entendo drift e como o plan o detecta.
- [ ] Sei que o state pode conter segredos em texto plano.
