# Gabarito comentado do simulado

1. **Falso.** `plan` é dry-run; nunca altera infra.
2. **(b) init.** Baixa providers e inicializa o backend.
3. **`-var` na CLI vence.** É a fonte de maior precedência.
4. **Falso.** `~> 3.4` permite 3.x mas bloqueia 4.0 (mudança de major).
5. **`terraform state rm`.** Remove do state; o objeto real continua existindo.
6. **Falso.** `sensitive` só oculta a saída do CLI. O state segue em texto plano.
7. **Falso.** `for_each` aceita map ou set of strings; uma list precisa de `toset(...)`.
8. **`terraform state mv`.** Renomeia/move no state sem destruir/recriar.
9. **Falso.** `version` só funciona com módulos do Registry/TFC, não com `source` local nem Git.
10. **S3** (com tabela **DynamoDB** para o lock, no modelo clássico da 003).
11. **`.terraform.lock.hcl`** — e **Verdadeiro**, deve ir para o Git.
12. **Falso.** `validate` é offline; não acessa APIs nem precisa de credenciais.
13. **Falso.** `taint` está deprecado; o recomendado é `terraform apply -replace`.
14. **`terraform.workspace`.**
15. **Falso.** No fluxo clássico `import` só popula o state; você escreve o bloco. (O bloco `import {}` do 1.5+ pode gerar com `-generate-config-out`.)
16. **(d) todas.** Compartilhamento, locking e criptografia.
17. **Verdadeiro.** Por isso nunca commitar o state e usar backend criptografado.
18. **0** (zero). Vai de 0 a N-1.
19. **`local-exec`.** Roda na máquina que executa o Terraform.
20. **`terraform apply -refresh-only`** (ou o legado `terraform refresh`).
21. **Falso.** `data` apenas lê/consulta; não cria.
22. **Declarativo.** Você descreve o estado final desejado.
23. **`*.auto.tfvars`** (carregados automaticamente, em ordem alfabética).
24. **Falso.** O workspace `default` não pode ser deletado.
25. **Nos runners da plataforma** (remote operations da HCP Terraform).

## Como interpretar seu resultado
- **22–25 acertos (≥ 88%):** pronto para marcar a prova.
- **18–21 (72–84%):** quase lá; refaça os labs dos temas que errou.
- **< 18 (< 72%):** volte aos labs 02, 04, 06, 07 e 08 antes de seguir.
