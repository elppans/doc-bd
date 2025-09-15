# Verificar se uma tabela depende de outra especifica

Dá pra verificar se uma tabela depende de outra no PostgreSQL — especialmente útil quando há **chaves estrangeiras**, **views**, **triggers** ou **funções** que criam vínculos entre objetos.

### 🧠 Como identificar dependências entre tabelas

Aqui estão algumas abordagens que você pode usar:

---

#### 🔍 1. **Verificar chaves estrangeiras**
Se você quer saber se uma tabela depende de outra via **foreign key**, este comando ajuda:

```sql
SELECT
    conname AS constraint_name,
    conrelid::regclass AS dependent_table,
    confrelid::regclass AS referenced_table
FROM
    pg_constraint
WHERE
    contype = 'f'
    AND confrelid::regclass::text = 'nome_da_tabela_referenciada';
```

Substitua `'nome_da_tabela_referenciada'` pela tabela que você quer verificar se é referenciada.

---

#### 🧠 2. **Verificar dependências gerais (views, triggers, etc.)**
Se quiser algo mais abrangente, como dependências de **views** ou **funções**, você pode usar:

```sql
SELECT
    dependent_ns.nspname AS dependent_schema,
    dependent_view.relname AS dependent_object,
    source_ns.nspname AS source_schema,
    source_table.relname AS source_table,
    pg_attribute.attname AS column_name
FROM
    pg_depend
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
JOIN pg_class AS dependent_view ON pg_rewrite.ev_class = dependent_view.oid
JOIN pg_class AS source_table ON pg_depend.refobjid = source_table.oid
JOIN pg_attribute ON pg_depend.refobjid = pg_attribute.attrelid
    AND pg_depend.refobjsubid = pg_attribute.attnum
JOIN pg_namespace dependent_ns ON dependent_ns.oid = dependent_view.relnamespace
JOIN pg_namespace source_ns ON source_ns.oid = source_table.relnamespace
WHERE
    source_table.relname = 'nome_da_tabela'
ORDER BY 1, 2;
```

Esse script mostra objetos que **dependem de colunas específicas** da tabela indicada.

---

#### 📚 Documentação oficial
O PostgreSQL tem um sistema robusto de rastreamento de dependências. Você pode entender melhor como ele funciona na [documentação oficial sobre Dependency Tracking](https://www.postgresql.org/docs/current/ddl-depend.html).
___

No PostgreSQL, a forma mais direta de identificar se uma tabela **depende de outra** — no sentido de que ela **faz referência a outra** — é através das **constraints do tipo `FOREIGN KEY`**.

Essas constraints são registradas no catálogo interno `pg_constraint`, e indicam que uma coluna (ou conjunto de colunas) de uma tabela aponta para a chave primária (ou única) de outra. Ou seja:

- Se a tabela **A** tem uma `FOREIGN KEY` que aponta para a tabela **B**, então **A depende de B**.
- Isso significa que **A não pode existir sem B**, porque seus dados estão vinculados.

---

### 🔎 Quer ver se uma tabela depende de outras?

Use este SELECT para descobrir **de quem uma tabela depende**:

```sql
SELECT
    conname AS nome_da_constraint,
    confrelid::regclass AS tabela_referenciada,
    conrelid::regclass AS tabela_dependente
FROM
    pg_constraint
WHERE
    contype = 'f'
    AND conrelid::regclass::text = 'sua_tabela_aqui';
```

📌 Substitua `'sua_tabela_aqui'` pela tabela que você quer investigar.

---

### 🧠 Dica extra

Se quiser ver **todas as dependências cruzadas** entre tabelas, pode montar uma visão geral com:

```sql
SELECT
    conrelid::regclass AS tabela_dependente,
    confrelid::regclass AS tabela_referenciada
FROM
    pg_constraint
WHERE
    contype = 'f';
```

Isso te dá um mapa completo das relações entre tabelas no banco.
___

# Exemplo usando tab_loja

Se quer saber **de quais outras tabelas `tab_loja` depende** — ou seja, quais tabelas ela **referencia via chave estrangeira** — o caminho é consultar as constraints do tipo `FOREIGN KEY` onde `tab_loja` é a tabela que contém a referência.

---

### 🔍 SELECT para ver **de quem `tab_loja` depende**

```sql
SELECT
    conname AS nome_da_constraint,
    confrelid::regclass AS tabela_referenciada,
    conrelid::regclass AS tabela_dependente,
    a.attname AS coluna_referenciada
FROM
    pg_constraint c
JOIN pg_class r ON r.oid = c.confrelid
JOIN pg_class d ON d.oid = c.conrelid
JOIN pg_attribute a ON a.attrelid = c.confrelid AND a.attnum = ANY(c.confkey)
WHERE
    c.contype = 'f'
    AND c.conrelid::regclass::text = 'tab_loja';
```

---

### 🧠 O que esse SELECT mostra:

- **`tabela_referenciada`**: a tabela que precisa existir antes da `tab_loja`
- **`coluna_referenciada`**: a coluna da outra tabela que está sendo referenciada
- **`nome_da_constraint`**: o nome da constraint que define essa dependência

---

### 💡 Exemplo de saída

| nome_da_constraint | tabela_referenciada | tabela_dependente | coluna_referenciada |
|--------------------|---------------------|--------------------|----------------------|
| fk_loja_cidade     | tab_cidade          | tab_loja           | id_cidade            |

Isso significa que `tab_loja` depende da existência de `tab_cidade`, porque ela tem uma `FOREIGN KEY` apontando para `id_cidade`.
___

A coluna `tabela_referenciada` no resultado do seu SELECT mostra as **tabelas que precisam existir previamente**, porque a `tab_loja` **depende delas via chave estrangeira**. Ou seja:

- A `tab_loja` tem colunas que fazem referência a essas tabelas.
- Se uma dessas tabelas referenciadas não existir, o PostgreSQL **não permite criar ou manter** a `tab_loja` com essas constraints ativas.
- Isso garante a **integridade referencial**: os dados em `tab_loja` só fazem sentido se os dados nas tabelas referenciadas estiverem lá.

---

### 🔗 Exemplo prático do seu resultado:

| tabela_dependente | tabela_referenciada |
|-------------------|---------------------|
| tab_loja          | tab_servidor        |
| tab_loja          | tab_municipio       |
| tab_loja          | tab_grupo_loja      |
| tab_loja          | tab_empresa         |
| tab_loja          | tab_ibpt            |

👉 Isso significa que **tab_loja depende dessas cinco tabelas**. Se você tentasse criar `tab_loja` sem que, por exemplo, `tab_empresa` existisse, o PostgreSQL lançaria erro na criação da `FOREIGN KEY`.


___


