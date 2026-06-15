# Terraform do Zero à Certificação — Guia com 10 Labs Práticos

> Trilha prática para passar na **HashiCorp Certified: Terraform Associate (003)** partindo do zero absoluto.
> Cada etapa é um lab executável de verdade. Sem analogias: você roda, vê o resultado e entende o porquê.

---

## Como este guia funciona

São **10 etapas** com dificuldade crescente. Cada etapa tem:

- **Objetivo da etapa** — o que você sai sabendo.
- **Conceito direto** — a teoria mínima, escrita para quem programa.
- **Lab** — passo a passo com arquivos `.tf` reais na pasta `labs/NN-nome/`.
- **Comandos** — exatamente o que digitar no terminal.
- **Armadilhas da prova** — o que a HashiCorp gosta de cobrar e onde candidatos erram.
- **Mentalidade de programador** — como mapear o conceito para algo que você já conhece (variáveis, funções, dependências, estado).
- **Checklist** — só avance quando marcar tudo.

### Por que os labs usam `local`, `random`, `null` e `docker`?

Você **não precisa de conta na AWS/Azure/GCP** para aprender Terraform nem para passar na prova. A prova testa o *Terraform em si* (workflow, state, módulos, expressões), não um provedor específico. Usando providers que rodam na sua máquina, você executa `apply` de verdade centenas de vezes sem custo e sem risco. Onde um conceito só aparece em nuvem, eu mostro o equivalente em AWS como **comentário**.

---

## Pré-requisitos (instalação)

```bash
# 1. Instale o Terraform (Linux)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# macOS
brew tap hashicorp/tap && brew install hashicorp/tap/terraform

# Verifique
terraform version

# 2. (Etapas 9-10) Docker, para labs com infraestrutura "real" local
docker --version
```

> Dica de programador: configure o autocomplete (`terraform -install-autocomplete`) e o realce de sintaxe HCL no seu editor (extensão oficial "HashiCorp Terraform" no VS Code). Vai economizar horas.

---

## Mapa das 10 etapas

| # | Etapa | Domínio da prova | Dificuldade |
|---|-------|------------------|-------------|
| 01 | [Fundamentos e o workflow core](labs/01-fundamentos/) | IaC, propósito do Terraform, init/plan/apply/destroy | ⭐ |
| 02 | [Variáveis, outputs e tipos](labs/02-variaveis-outputs/) | Ler/gerar/modificar configuração | ⭐ |
| 03 | [Providers, versionamento e dependências](labs/03-providers-dependencias/) | Terraform basics | ⭐⭐ |
| 04 | [State: o coração do Terraform](labs/04-state/) | Implementar e manter state | ⭐⭐ |
| 05 | [Expressões, funções, locals e condicionais](labs/05-expressoes-funcoes/) | Ler/gerar/modificar configuração | ⭐⭐⭐ |
| 06 | [count, for_each e loops](labs/06-count-foreach/) | Ler/gerar/modificar configuração | ⭐⭐⭐ |
| 07 | [Módulos: criar e consumir](labs/07-modulos/) | Interagir com módulos | ⭐⭐⭐ |
| 08 | [Backends remotos e workspaces](labs/08-backend-workspaces/) | Implementar e manter state | ⭐⭐⭐⭐ |
| 09 | [Workflow fora do core: import, replace, fmt, validate, provisioners](labs/09-fora-do-core/) | Usar Terraform fora do workflow core | ⭐⭐⭐⭐ |
| 10 | [Terraform Cloud/HCP, segurança e simulado final](labs/10-cloud-seguranca-revisao/) | Terraform Cloud + revisão geral | ⭐⭐⭐⭐⭐ |

---

## Estratégia de prova (leia antes de começar)

Pense como um estrategista, não só como estudante:

1. **Formato:** ~57 questões, 1 hora, online com proctor. Múltipla escolha, múltipla resposta, e verdadeiro/falso. Aprovação fica em torno de 70% (a HashiCorp não publica o número exato). Sem penalidade por erro → **nunca deixe questão em branco**.

2. **A prova é conceitual, não decoreba de sintaxe.** Eles raramente pedem "qual o nome exato do argumento". Eles pedem: "o que acontece com o state se você fizer X?", "qual comando você usa quando Y?", "qual a ordem de criação dada esta dependência?".

3. **Os 3 temas que mais derrubam gente:**
   - **State** (etapas 04 e 08): locking, backends, `terraform state` subcomandos, drift, sensitive data no state.
   - **Variáveis e precedência** (etapa 02): a ordem exata em que valores sobrescrevem uns aos outros.
   - **Módulos e fontes** (etapa 07): sintaxe de `source`, versionamento, inputs/outputs.

4. **Decore de verdade só 4 coisas:**
   - A **precedência de variáveis** (etapa 02).
   - A **ordem do workflow** e o que cada comando faz (etapa 01).
   - Os **subcomandos de `terraform state`** (etapa 04).
   - O que vai **plaintext no state** e por que sensitive não criptografa o state (etapa 10).

5. **Técnica de aprendizado para programador:** depois de cada lab, rode `terraform plan` *antes* de aplicar e tente prever a saída linha a linha. Acertar o plano de cabeça é o melhor preditor de aprovação. Trate o `plan` como você trataria a leitura de um `git diff` antes do commit.

6. **Recurso oficial obrigatório:** ao final, leia o [Exam Review](https://developer.hashicorp.com/terraform/tutorials/certification-003) da HashiCorp e a documentação que cada etapa linka. A prova é fiel à documentação oficial.

---

## Como usar o repositório

```bash
git clone <este-repo>
cd learn-terraform-claude

# Vá para a primeira etapa e siga o README de lá
cd labs/01-fundamentos
cat README.md
```

Cada pasta `labs/NN-*` é autocontida: tem seu próprio README, os arquivos `.tf` e um exercício no final. Comece pela 01 e só avance quando o checklist estiver completo.

Bons estudos — e bom `apply`. 🚀
