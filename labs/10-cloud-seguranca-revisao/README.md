# Etapa 10 — Terraform Cloud/HCP, segurança e simulado final ⭐⭐⭐⭐⭐

## Objetivo
Fechar os dois domínios restantes (**Terraform Cloud/HCP** e **segurança/dados sensíveis**), revisar tudo com um **cheat sheet**, e treinar com um **simulado de 25 questões** comentadas.

---

## Parte A — Terraform Cloud / HCP Terraform

**HCP Terraform** (antigo Terraform Cloud) é a plataforma SaaS da HashiCorp para rodar Terraform em equipe. **Terraform Enterprise** é a versão self-hosted (mesmas ideias, instalada na sua infra).

Recursos que a prova cobra:
- **Remote state** gerenciado + **state locking** automático.
- **Remote operations**: `plan`/`apply` rodam nos runners da plataforma, não na sua máquina.
- **VCS integration**: conecta a um repositório; push abre um plan automático (**speculative plan** em PRs).
- **Workspaces** (na nuvem): cada um tem state, variáveis e histórico próprios. Diferente dos workspaces de CLI da etapa 08.
- **Variáveis e variáveis sensíveis** definidas na UI; podem ser **terraform variables** ou **environment variables**.
- **Sentinel** e **OPA**: *policy as code* — políticas que barram um apply que viole regras (ex.: "proibir instância sem tag").
- **Private Module Registry**: registry privado de módulos da sua org.
- **Cost estimation**: estimativa de custo antes do apply.
- **Run workflow**: VCS-driven, CLI-driven ou API-driven.

Conexão via CLI:
```hcl
terraform {
  cloud {
    organization = "minha-org"
    workspaces { name = "app-prod" }
  }
}
```
```bash
terraform login    # gera token e autentica na HCP Terraform
```

Camadas: há um tier **gratuito** para times pequenos; recursos como Sentinel/SSO ficam em tiers pagos.

---

## Parte B — Segurança e dados sensíveis (tema que derruba gente)

Verdades que a prova exige:
1. **O state guarda valores em TEXTO PLANO**, inclusive senhas e chaves geradas (ex.: `random_password`, senha de RDS). Logo:
   - **Nunca commite o `terraform.tfstate`** no Git.
   - Use **backend remoto com criptografia** e controle de acesso.
2. `sensitive = true` (em variável ou output) **só oculta o valor da saída do CLI** (`plan`/`apply`/`output`). **Não criptografa o state** e não impede o valor de existir lá.
3. **Não coloque segredos em texto** nos `.tf` versionados. Use:
   - Variáveis sensíveis (env `TF_VAR_...` ou na HCP).
   - **Vault provider** / data sources para buscar segredos em tempo de execução.
   - Gerenciadores de segredo do provider (AWS Secrets Manager, etc.) via `data`.
4. Autenticação ao provider: prefira **variáveis de ambiente / roles**, nunca credenciais hardcoded no código.
5. `terraform output -json` **mostra** valores sensíveis (para consumo por máquina) — cuidado em logs/CI.

```hcl
variable "senha_db" {
  type      = string
  sensitive = true     # oculta no output do CLI...
}
output "senha" {
  value     = var.senha_db
  sensitive = true     # ...mas continua em texto plano no STATE
}
```

---

## Parte C — Data sources (revisão importante)

`data` = **ler** algo que já existe (não cria nada). Ex.: buscar uma AMI, uma VPC, um segredo.
```hcl
data "local_file" "config" {
  filename = "${path.module}/entrada.txt"
}
# uso: data.local_file.config.content
```
Diferença para `resource`: `resource` **gerencia** (cria/altera/destroi); `data` só **consulta**.

---

## Lab final (data source + sensitive, roda local)

```bash
cd labs/10-cloud-seguranca-revisao
echo "dado externo lido via data source" > entrada.txt
terraform init
terraform apply -auto-approve

terraform output                # 'segredo' aparece como (sensitive)
terraform output -json          # aqui o valor APARECE — entenda o risco
grep -i senha terraform.tfstate # PROVE que está em texto plano no state!

terraform destroy -auto-approve
```
O `grep` no state é o experimento mais importante desta etapa: você **vê com os próprios olhos** o segredo em texto plano. Isso fixa o conceito para a prova.

---

## Cheat sheet final (revise na véspera)

**Workflow:** `init` (baixa providers/backend) → `plan` (dry-run) → `apply` (aplica) → `destroy` (remove).

**Precedência de variáveis (fraco→forte):** default → `TF_VAR_*` → `terraform.tfvars` → `*.auto.tfvars` (alfabética) → `-var`/`-var-file`.

**Versão `~> 1.2`:** permite 1.x ≥ 1.2, bloqueia 2.0. `~> 1.2.3`: só 1.2.x.

**State commands:** `list`, `show`, `mv` (renomear sem recriar), `rm` (esquece, não apaga real), `pull`, `push`.

**count vs for_each:** `count`→índice numérico, sofre com remoção do meio; `for_each`→chave string, estável, precisa map/set.

**Módulos:** todo dir é módulo; `version` só para Registry/TFC; Git fixa por `?ref=`; recursos viram `module.x.*`.

**Backend remoto:** compartilha state + locking + criptografia. S3 clássico usa DynamoDB p/ lock. Bloco `backend` não aceita variáveis.

**Workspaces:** múltiplos states, `terraform.workspace`, padrão `default`. Não isolam credenciais.

**Fora do core:** `fmt`, `validate` (offline), `import` (só state, não gera código no fluxo clássico), `apply -replace` (substitui `taint`), `-refresh-only`.

**Provisioners:** último recurso; `local-exec`/`remote-exec`/`file`; falha na criação → tainted; `when=destroy`.

**Segurança:** state em texto plano; `sensitive` só oculta CLI; nunca commitar state; usar Vault/secret manager.

**Arquivos:** `.terraform.lock.hcl` → vai pro Git. `.terraform/` e `*.tfstate` → NÃO vão pro Git.

---

## Simulado final (25 questões)

Responda mentalmente, depois confira em `GABARITO.md`. Meta: **≥ 80%** antes de marcar a prova.

1. `terraform plan` pode alterar a infraestrutura. (V/F)
2. Qual comando baixa os providers? (a) plan (b) init (c) apply (d) get
3. Na precedência de variáveis, quem vence: `-var` na CLI ou `terraform.tfvars`?
4. `~> 3.4` permite a versão 4.0? (V/F)
5. Qual comando remove um recurso do state sem destruir o objeto real?
6. `sensitive = true` criptografa o state. (V/F)
7. `for_each` aceita uma `list(string)` diretamente. (V/F)
8. Você renomeou um recurso no código. Que comando evita destruí-lo/recriá-lo?
9. O argumento `version` em um bloco `module` funciona com `source` local. (V/F)
10. Qual backend clássico usa DynamoDB para state locking?
11. Em que arquivo ficam travadas as versões dos providers, e ele vai para o Git? (V/F do "vai para o Git")
12. `terraform validate` precisa de credenciais do provider. (V/F)
13. `terraform taint` é o método recomendado hoje para forçar recriação. (V/F)
14. Qual expressão referencia o nome do workspace atual no código?
15. `terraform import` gera automaticamente o bloco `resource` no fluxo clássico. (V/F)
16. Múltipla escolha: quais são benefícios de um backend remoto? (a) compartilhar state (b) state locking (c) criptografia (d) todas
17. O state pode conter segredos em texto plano. (V/F)
18. `count.index` começa em qual número?
19. Qual provisioner roda na máquina que executa o Terraform?
20. Qual comando atualiza o state com a realidade sem alterar infraestrutura?
21. `data` sources criam recursos. (V/F)
22. Terraform é declarativo ou imperativo?
23. Qual arquivo `.tfvars` é carregado automaticamente além de `terraform.tfvars`?
24. O workspace padrão pode ser deletado. (V/F)
25. Onde rodam os `plan`/`apply` no modo de remote operations da HCP Terraform: na sua máquina ou nos runners da plataforma?

---

## Plano de revisão dos últimos 3 dias (estratégia de prova)

- **Dia -3:** refaça os labs 04 (state) e 08 (backend/workspaces) — os que mais derrubam. Releia a documentação oficial de state.
- **Dia -2:** refaça 02 (precedência), 06 (count/for_each), 07 (módulos). Faça o simulado acima.
- **Dia -1:** leia só o cheat sheet e o [Exam Review oficial](https://developer.hashicorp.com/terraform/tutorials/certification-003). Não estude conceito novo na véspera.
- **No dia:** leia cada questão duas vezes; marque para revisar as difíceis e volte; **não deixe nada em branco** (não há penalidade). Gerencie o tempo: ~1 min/questão, sobra tempo para revisar.

## Checklist final
- [ ] Sei o que é HCP Terraform e seus recursos (remote ops, VCS, Sentinel, private registry).
- [ ] Provei que o state guarda segredos em texto plano (`grep`).
- [ ] Sei exatamente o que `sensitive = true` faz e não faz.
- [ ] Diferencio `data` de `resource`.
- [ ] Acertei ≥ 80% do simulado.
- [ ] Revisei o cheat sheet inteiro sem consultar.
