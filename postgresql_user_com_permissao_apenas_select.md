# PostgreSQL. Criar um usuário com permissão a apenas o uso do Select

1 - Criar o usuário (Role)

```
CREATE USER usuario_leitura WITH PASSWORD 'sua_senha_segura';
```

2 - Conectar ao banco de dados correto  
3 - Conceder permissão de conexão e uso do Schema

```
-- Garante a conexão ao banco de dados
GRANT CONNECT ON DATABASE seu_banco_de_dados TO usuario_leitura;

-- Garante o uso do schema (necessário para acessar as tabelas dentro dele)
GRANT USAGE ON SCHEMA public TO usuario_leitura;
```

4 - Conceder a permissão de SELECT

- Para TODAS as tabelas atuais do schema:

```
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_leitura;
```

- Para tabelas específicas (caso queira restringir ainda mais):

```
GRANT SELECT ON TABLE nome_da_tabela TO usuario_leitura;
```

5 - Garantir acesso a tabelas FUTURAS

```
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO usuario_leitura;
```

---

- Outros Selects para confirmar o banco e usuários:
```
SELECT datname AS nome_do_banco from pg_database where datistemplate = false;
select * from pg_user ;
SELECT datname AS nome_do_banco,pg_catalog.pg_get_userbyid(datdba) AS dono from pg_database where datistemplate = false;
```
```
SELECT 
    d.datname AS nome_do_banco,
    COALESCE(u.rolname, 'PUBLIC (Todos os usuários)') AS usuario_com_acesso,
    a.privilege_type AS tipo_de_permissao
FROM pg_database d
CROSS JOIN LATERAL aclexplode(d.datacl) a
LEFT JOIN pg_roles u ON a.grantee = u.oid
WHERE d.datistemplate = false;
```
