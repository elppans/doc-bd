# PSQL, Criar usuário somente leitura

- **Observação**:   
Trocar "**usuario_banco**", "**senha_forte**" e "**nome_banco**" para o seu **usuário**, **senha** e **banco**.

```sql
-- lista schemas
SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- Lista os bancos e o "dono" respectivo
SELECT datname AS nome_do_banco,pg_catalog.pg_get_userbyid(datdba) AS dono from pg_database where datistemplate = false;

-- cria o usuário
CREATE USER usuario_banco WITH PASSWORD 'senha_forte';

-- Listar usuários do banco
select * from pg_user ;

-- permite conectar no banco
GRANT CONNECT ON DATABASE nome_banco TO usuario_banco;

-- acesso ao schema public
GRANT USAGE ON SCHEMA public TO usuario_banco;

-- leitura das tabelas existentes
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_banco;

-- leitura das sequências (caso necessário)
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO usuario_banco;

-- garante leitura automática nas tabelas criadas futuramente
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO usuario_banco;
```
