# PostgreSQL, Backup apenas da `Extrutura do Banco`

Se você quer apenas a **estrutura** do banco — ou seja, os comandos para criar tabelas, índices, funções, etc., mas **sem os dados** — é só usar o parâmetro `--schema-only`.

### 🛠 Comando básico:
```bash
pg_dump --schema-only -U seu_usuario -d nome_do_banco > estrutura.sql
```

### 🔍 Explicando os parâmetros:
- `--schema-only`: exporta apenas a estrutura (DDL), sem os dados.
- `-U seu_usuario`: define o usuário do PostgreSQL.
- `-d nome_do_banco`: nome do banco que você quer exportar.
- `> estrutura.sql`: redireciona a saída para um arquivo `.sql`.

### ✅ Exemplo prático:
```bash
pg_dump --schema-only -U postgres -d minha_base > dump_estrutura.sql
```

Esse arquivo gerado (`dump_estrutura.sql`) vai conter os comandos `CREATE TABLE`, `CREATE INDEX`, `ALTER TABLE`, etc., mas nenhum `INSERT`.

Se quiser filtrar ainda mais — por exemplo, exportar só algumas tabelas específicas — também dá pra fazer com `--table`:

```bash
pg_dump --schema-only --table=nome_da_tabela -U postgres -d minha_base > tabela_estrutura.sql
```
___
