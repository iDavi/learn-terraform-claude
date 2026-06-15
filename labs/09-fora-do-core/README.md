# Etapa 09 — Workflow fora do core: import, replace, fmt, validate, provisioners ⭐⭐⭐⭐

## Objetivo
Dominar os comandos que **não** fazem parte do init/plan/apply/destroy mas caem na prova: `fmt`, `validate`, `import`, `apply -replace` (ex-`taint`), `-refresh-only`, `output`, `console`, e os **provisioners** (com suas armadilhas).

## Conceito direto

### Comandos de higiene
- `terraform fmt` — formata os `.tf` no estilo canônico. `-recursive` para subpastas, `-check` para CI.
- `terraform validate` — valida sintaxe e consistência interna (**não** acessa APIs, **não** precisa de credenciais). Roda após `init`.
- `terraform show` — exibe state/plan de forma legível.
- `terraform output [-json]` — lê outputs do state.
- `terraform console` — REPL (visto na etapa 05).
- `terraform graph` — grafo de dependências.
- `terraform providers` — mostra os providers usados.

### Trazer recurso existente para o Terraform: `import`
Quando um recurso **já existe** (criado à mão ou por outro processo) e você quer gerenciá-lo:
```bash
# 1. Escreva o bloco resource vazio no .tf
# 2. Importe o recurso real para o state:
terraform import local_file.existente ./manual.txt
```
- `import` **só mexe no state** — ele **não gera código**. Você precisa escrever o bloco `resource` à mão (ou usar o bloco `import {}` declarativo do Terraform 1.5+, que pode gerar código com `-generate-config-out`).
- Sintaxe: `terraform import <ADDRESS> <ID>`. O `<ID>` depende do recurso (na AWS, o id do recurso; aqui, o caminho).

### Forçar recriação: `taint` / `-replace`
- Antigo: `terraform taint <addr>` marca para recriar no próximo apply. **Está deprecado.**
- Atual (recomendado): `terraform apply -replace="<addr>"` — recria aquele recurso específico.
- `terraform untaint` desmarca um taint.

### Refresh e drift
- `terraform apply -refresh-only` (ou o legado `terraform refresh`) — atualiza o state com a realidade **sem** alterar infraestrutura. Útil para detectar/absorver drift.
- `terraform plan -refresh=false` — pula o refresh (plan mais rápido, pode não ver drift).

### Provisioners (use como ÚLTIMO recurso)
Executam scripts durante create/destroy. A própria HashiCorp diz: **provisioners são o último recurso** — prefira ferramentas nativas (user_data, cloud-init, configuração via API).
- `local-exec` — roda comando na máquina que executa o Terraform.
- `remote-exec` — roda comando no recurso remoto (via SSH/WinRM).
- `file` — copia arquivos para o recurso.
- `when = destroy` — provisioner roda na destruição.
- `on_failure = continue | fail` (padrão `fail`).
- Provisioner é **declarado dentro do `resource`** e por padrão roda na **criação**.
- Se um provisioner de criação falha, o recurso é marcado como **tainted** (será recriado no próximo apply).

## Mentalidade de programador
- `validate` = linter/typecheck (offline); `fmt` = prettier/gofmt.
- `import` = adotar um objeto que já existe no "banco" sem recriá-lo (como mapear uma tabela legada num ORM).
- `-replace` = forçar um rebuild daquele artefato específico.
- provisioner = um "hook" pós-deploy; igual a evitar lógica no `postinstall` do npm, você evita provisioner quando dá.

## Lab

### Passo 1 — fmt e validate
```bash
cd labs/09-fora-do-core
terraform init
terraform fmt          # formata (experimente bagunçar o main.tf antes)
terraform validate     # deve dizer "Success!"
```

### Passo 2 — provisioner local-exec
O `main.tf` tem um `null_resource` com `local-exec` que escreve em um log. Aplique:
```bash
terraform apply -auto-approve
cat provisioner.log     # criado pelo local-exec
```

### Passo 3 — force a recriação com -replace
```bash
terraform apply -auto-approve -replace="null_resource.tarefa"
cat provisioner.log     # o provisioner rodou de novo (recurso recriado)
```

### Passo 4 — import na prática
Crie um arquivo "à mão" e adote-o:
```bash
echo "criado fora do terraform" > manual.txt

# O bloco resource "local_file" "existente" já está comentado no main.tf.
# Descomente-o, depois:
terraform import local_file.existente ./manual.txt
terraform state list           # local_file.existente agora está no state
terraform plan                 # ajuste o content do bloco até dar "No changes"
```

### Passo 5 — refresh-only
```bash
echo "alterado por fora" > manual.txt
terraform apply -refresh-only -auto-approve   # state atualiza, infra não muda
terraform plan                                # mostra o que o TF faria para reconciliar
```

### Passo 6 — limpe
```bash
terraform destroy -auto-approve
```

## Armadilhas da prova
- `terraform validate` **não** precisa de credenciais nem acessa provider APIs — valida só a configuração.
- `terraform import` **não gera configuração** (no fluxo clássico) — você escreve o bloco antes. Ele só popula o **state**.
- `taint` está **deprecado**; o recomendado é `apply -replace`.
- Provisioners são **último recurso** (a HashiCorp recomenda explicitamente evitá-los).
- Provisioner de criação que falha → recurso fica **tainted** (recriado no próximo apply); controle com `on_failure`.
- `when = destroy` faz o provisioner rodar na destruição.
- `-refresh-only` atualiza o state sem mudar infra.
- `terraform fmt -check` é o que se usa em pipeline de CI (falha se não estiver formatado).

## Mini-desafio
1. Adicione um provisioner `local-exec` com `when = destroy` e veja-o rodar no `destroy`.
2. Use `on_failure = continue` num comando que falha e observe o apply não abortar.
3. Pesquise o bloco `import {}` declarativo (TF 1.5+) e `-generate-config-out`.

## Checklist
- [ ] Sei o que `validate` faz (e que é offline).
- [ ] Sei usar `import` e que ele só mexe no state.
- [ ] Sei que `-replace` substituiu o `taint`.
- [ ] Sei o que é `-refresh-only`.
- [ ] Conheço os 3 provisioners e sei que são último recurso.
- [ ] Sei o efeito de um provisioner de criação que falha (tainted).
