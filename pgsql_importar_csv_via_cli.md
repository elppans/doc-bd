# Importar CSV para o PostgreSQL via CLI

Existem duas formas principais de importar CSV para o PostgreSQL via CLI:

---

### **1. Pelo `psql` (direto no cliente)**

Se o arquivo CSV está no mesmo servidor onde roda o `psql`, você pode usar o comando `\copy`:

```bash
psql -U postgres -d db_burisrv -c "\copy nome_tabela FROM '/caminho/arquivo.csv' DELIMITER ';' CSV HEADER"
```

* `DELIMITER ';'` → ajusta o separador (mude se for `,` ou outro)
* `CSV HEADER` → ignora a primeira linha (cabeçalho do CSV)
* `\copy` (com barra) → roda no cliente, não precisa de permissões especiais no servidor

---

### **2. Pelo SQL padrão (necessita permissão no servidor)**

Se o CSV está no **servidor** e o PostgreSQL tem acesso direto ao arquivo:

```sql
COPY nome_tabela
FROM '/caminho/arquivo.csv'
DELIMITER ';'
CSV HEADER;
```

⚠️ Essa forma exige que o usuário do PostgreSQL (normalmente `postgres`) tenha permissão de leitura no arquivo.

---

🔎 Resumindo:

* Use `\copy` quando você está no cliente `psql` (mais seguro e prático).
* Use `COPY` quando o arquivo está disponível para o servidor PostgreSQL e você tem permissão.

---

Quer que eu já monte um **script bash** que leia todos os `.csv` de um diretório e importe cada um para a tabela de mesmo nome automaticamente?

___

# Testar para saber se a importação daria certo

Você pode **simular a importação** de várias formas antes de mexer nos dados de verdade.

Aqui vão 3 jeitos de testar com segurança:

---

### 🔹 1. Testar sintaxe / acesso ao arquivo sem gravar nada

Use a opção `--dry-run` no `psql` (não existe diretamente 😅), mas podemos “forçar” um teste criando uma tabela temporária:

```bash
psql -U postgres -d db_burisrv -c "CREATE TEMP TABLE tmp_import (LIKE nome_tabela INCLUDING ALL);"
psql -U postgres -d db_burisrv -c "\copy tmp_import FROM '/caminho/arquivo.csv' DELIMITER ';' CSV HEADER"
```

* Isso importa o CSV numa tabela **temporária**, que some quando você fecha a sessão.
* Se funcionar, significa que a importação real também vai funcionar.

---

### 🔹 2. Usar transação e dar ROLLBACK

Você pode abrir uma transação, importar, verificar, e se não gostar, dar rollback:

```bash
psql -U postgres -d db_burisrv

BEGIN;
\copy nome_tabela FROM '/caminho/arquivo.csv' DELIMITER ';' CSV HEADER;

-- aqui você pode até dar um SELECT pra conferir
SELECT COUNT(*) FROM nome_tabela;

-- se não gostar:
ROLLBACK;

-- se quiser manter:
COMMIT;
```

---

### 🔹 3. Importar só uma amostra do CSV

No Linux, dá pra pegar só as primeiras linhas do CSV e tentar importar:

```bash
head -n 20 arquivo.csv > teste.csv
psql -U postgres -d db_burisrv -c "\copy nome_tabela FROM 'teste.csv' DELIMITER ';' CSV HEADER"
```

Assim você testa estrutura e compatibilidade sem arriscar a massa de dados inteira.

---

✅ **Resumindo:**
O mais seguro é usar **tabela temporária** ou **transação com ROLLBACK**. Dessa forma você garante 100% que não altera os dados originais até ter certeza.

---

👉 Você prefere que eu te escreva um **script pronto** que já importe todos os CSVs para tabelas temporárias (só pra teste), e depois, se ficar tudo certo, você troca pra tabelas reais?

___

# Tabelas temporárias
Dá sim 👍

As **tabelas temporárias** somem automaticamente quando a sessão acaba, mas você também pode derrubar manualmente a qualquer momento.

Basta rodar:

```sql
DROP TABLE tmp_import;
```

Isso remove a tabela temporária imediatamente, mesmo dentro da mesma sessão.

---

### Exemplo completo no `psql`:

```bash
psql -U postgres -d db_burisrv
```

E dentro do cliente:

```sql
-- cria tabela temporária igual à original
CREATE TEMP TABLE tmp_import (LIKE nome_tabela INCLUDING ALL);

-- testa importação
\copy tmp_import FROM '/caminho/arquivo.csv' DELIMITER ';' CSV HEADER;

-- confere os dados
SELECT * FROM tmp_import LIMIT 5;

-- se quiser descartar antes de sair
DROP TABLE tmp_import;
```

---

✅ Assim você consegue testar quantas vezes quiser, limpando no final.

👉 Quer que eu te monte um **script bash** que já crie a `tmp_import`, rode a `\copy`, mostre a contagem de linhas importadas e depois faça o `DROP TABLE` automático?


