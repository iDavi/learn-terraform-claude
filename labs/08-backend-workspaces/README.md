# Etapa 08 — Backends remotos e workspaces ⭐⭐⭐⭐

## Objetivo
Entender **backends** (onde o state vive), o **state locking**, e **workspaces** (múltiplos states do mesmo código). Você vai praticar com um backend local e entender o remoto.

## Conceito direto

### Backend = onde o state é guardado e como as operações rodam
- **Local** (padrão): `terraform.tfstate` na pasta. Bom para estudo, ruim para equipe.
- **Remoto**: state num local compartilhado (S3, Azure Blob, GCS, Terraform Cloud, Consul...). Necessário para **trabalho em equipe**.

Benefícios do backend remoto (a prova adora):
1. **State compartilhado** entre o time.
2. **State locking**: impede dois `apply` simultâneos corromperem o state. (Ex.: S3 + DynamoDB faz o lock; Terraform Cloud e Azure/GCS fazem nativamente.)
3. **Criptografia em repouso** e em trânsito.
4. **Não fica no disco/Git** de ninguém (segredos protegidos).

Exemplo de configuração de backend (não roda sem AWS, é só para você reconhecer):
```hcl
terraform {
  backend "s3" {
    bucket         = "minha-empresa-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"   # state locking
    encrypt        = true
  }
}
```
- O bloco `backend` fica dentro de `terraform {}` e **não aceita variáveis/expressões** (precisa ser valor literal) — você passa valores parciais via `-backend-config` no `init`.
- Trocar de backend exige `terraform init` (ele oferece **migrar o state**).

### Locking
- Em `apply`/`plan`, o Terraform adquire um **lock** para que ninguém mais altere o state ao mesmo tempo.
- `terraform force-unlock <LOCK_ID>` libera um lock travado (use com cuidado).
- `-lock=false` desativa (perigoso; cobrado como "o que NÃO fazer em equipe").

### Workspaces
Permitem **múltiplos states isolados** a partir do mesmo código (ex.: `dev`, `staging`, `prod`).
```bash
terraform workspace list           # lista (o padrão é "default")
terraform workspace new dev        # cria e troca
terraform workspace select prod    # troca
terraform workspace show           # workspace atual
```
- Dentro do código: `terraform.workspace` (string com o nome).
- Com backend local, os states ficam em `terraform.tfstate.d/<workspace>/`.
- **Cuidado de prova:** workspaces **não** são isolamento forte de credenciais/ambiente; são apenas múltiplos states. Para separação real de prod, muitos times preferem diretórios/backends distintos.

## Mentalidade de programador
- Backend remoto = mover o "banco de dados de state" de SQLite local para um Postgres compartilhado com lock de transação.
- State locking = lock de escrita / mutex para evitar corrida.
- Workspace = mesmo código, "schema" de banco diferente por ambiente. `terraform.workspace` é como uma env var de ambiente.

## Lab

### Passo 1 — workspaces na prática (roda com backend local)
```bash
cd labs/08-backend-workspaces
terraform init
terraform workspace show          # default

terraform workspace new dev
terraform apply -auto-approve
cat ambiente.txt                  # diz "dev" (usou terraform.workspace)

terraform workspace new prod
terraform apply -auto-approve
cat ambiente.txt                  # agora "prod" — state separado!

terraform workspace list          # default, dev, prod
ls -R terraform.tfstate.d         # states isolados por workspace
```

### Passo 2 — confirme o isolamento
```bash
terraform workspace select dev
terraform output                  # output do workspace dev
terraform workspace select prod
terraform output                  # output do workspace prod (independente)
```

### Passo 3 — entenda o backend remoto (leitura)
Abra `backend-remoto-exemplo.tf.txt` nesta pasta: é um exemplo comentado de backend S3 com locking. Não vamos aplicar (precisa de AWS), mas você deve **reconhecer cada argumento na prova**.

### Passo 4 — limpe
```bash
terraform workspace select dev
terraform destroy -auto-approve
terraform workspace select prod
terraform destroy -auto-approve
terraform workspace select default
terraform workspace delete dev
terraform workspace delete prod
```

## Armadilhas da prova
- Backend remoto resolve **3 coisas**: compartilhamento, locking e segurança/criptografia.
- **S3 sozinho não faz locking** no modelo clássico — precisa de **DynamoDB** (`dynamodb_table`). (Versões recentes têm lock nativo via `use_lockfile`, mas a prova 003 ainda foca no DynamoDB.)
- O bloco `backend` **não aceita variáveis** — use `-backend-config`.
- Trocar/mudar backend exige `terraform init` (com opção de migrar state).
- `terraform.workspace` referencia o nome do workspace atual no código.
- Workspaces **não isolam credenciais**; são múltiplos states do mesmo backend.
- O workspace padrão chama-se **`default`** e **não pode ser deletado**.
- `terraform force-unlock` remove um lock preso; `-lock=false` desativa locking (não recomendado).

## Mini-desafio
1. Use `terraform.workspace` numa condição (ex.: `count = terraform.workspace == "prod" ? 2 : 1`).
2. Liste o conteúdo de `terraform.tfstate.d/` e explique a estrutura.
3. Escreva (sem aplicar) um bloco `backend "local" { path = "..." }` customizando o caminho do state.

## Checklist
- [ ] Sei os 3 benefícios do backend remoto.
- [ ] Sei que S3 precisa de DynamoDB para locking (modelo clássico).
- [ ] Sei que o bloco `backend` não aceita variáveis.
- [ ] Sei criar/trocar/listar workspaces e usar `terraform.workspace`.
- [ ] Entendo que workspace ≠ isolamento de credenciais.
