#	Comandos pgsql via Terminal:

### Select para Verificar a versão do PostgreSQL

```bash
SELECT version();
```

### Criar um Super Usuário no Banco:

```bash
psql -p 5432 -U postgres -c "CREATE USER NOMEUSUARIO SUPERUSER INHERIT CREATEDB CREATEROLE" -d template1
```
```bash
psql -p 5432 -U postgres -c "ALTER USER NOMEUSUARIO WITH PASSWORD 'SENHA'" -d template1
```

### Listar usuários:

```bash
psql -p 5432 -U postgres -c "SELECT usename FROM pg_user"
```

**OU**

```bash
psql -p 5432 -U postgres -c "SELECT * FROM pg_user"
```

### Listar bancos:

```bash
psql  -p 5432 -U postgres -l
```

### Criar banco:

```bash
createdb -U postgres NOMEBANCO NOMEBANCO
```
### Criar banco, com Encoding `LATIN1`, Collate/CType `ISO8859-1`:  

```
createdb -U postgres -E LATIN1 --locale=pt_BR.iso88591 -T template0 NOMEBANCO
```

### Renomear banco:

```bash
psql  -p 5432 -U postgres -c "ALTER DATABASE "NOMEBANCO" RENAME TO "NOVONOMEBANCO""
```

### Backup banco:

```bash
pg_dump --host 127.0.0.1 --port 5432 --username postgres --no-password  --format custom --blobs --verbose --file ~/NOMEBANCO.backup NOMEBANCO
```

### Restaurar banco:

```bash
pg_restore --host 127.0.0.1 --port 5432 --username postgres --dbname NOMEBANCO --no-password  --verbose ~/NOMEBANCO.backup
```

### Deletar banco:

```bash
dropdb -U postgres -p 5432 -h localhost -i -e NOMEBANCO -W
```

### Importar arquivo .sql:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -f arquivo.sql
```

### Exportar Banco para .DMP:

```bash
pg_dump --verbose --host 127.0.0.1 --port 5432 --username postgres -d NOMEBANCO > /opt/BDBKP/NOMEBANCO.dmp
```

### Importar .DMP para o Banco:

```bash
psql --host 127.0.0.1 --port 5432 --username postgres --file /opt/BDBKP/NOMEBANCO.dmp NOMEBANCO
```
```bash
psql --host 127.0.0.1 --port 5432 --username postgres -d NOMEBANCO -f /opt/custom/function.sql
```

### Executar comandos no psql:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "COMANDO"
```

### Verificar tamanho do Banco, em bytes:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "select pg_database_size('NOMEBANCO');"
```

### Verificar tamanho do banco
> Equivalente ao du -sh * na pasta base:  

##### Database Size: 

```bash
SELECT pg_size_pretty(pg_database_size('Database Name'));
```

##### Table Size:

```bash
SELECT pg_size_pretty(pg_relation_size('table_name'));
```

### Tamanho TODAS as tabelas do banco, em ordem de tamanho, do maior pro menor

```bash
SELECT table_name AS "NomeTabela",
       pg_size_pretty(pg_total_relation_size('"' || table_name || '"')) AS "Tamanho"
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size('"' || table_name || '"') DESC;
```

### Tamanho TODAS as tabelas do banco, em ordem de tamanho, do maior pro menor, tabelas de [10+ GB](https://github.com/elppans/doc-linux/blob/main/1024_em_computacao.md)

```bash
SELECT
  table_name,
  pg_size_pretty(total_size) AS total_size
FROM (
  SELECT
    table_name,
    pg_total_relation_size(quote_ident(table_schema) || '.' || quote_ident(table_name)) AS total_size
  FROM
    information_schema.tables
  WHERE
    table_schema = 'public' -- Substitua pelo esquema desejado, se aplicável
) AS table_sizes
WHERE
  total_size >= 10737418240 -- Tabelas de 10 GB ou mais (10 GB = 10 * 1024 * 1024 * 1024 bytes (10×2^30))
ORDER BY 
  total_size DESC
;
```

### Exportar Select para CSV:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv"
```



#### Exportar Select para CSV usando delimitadores:

```bash
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv HEADER"
```
```bash
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ',' HEADER"
```
```bash
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ';' HEADER"
```
```bash
"copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' (DELIMITER ';');"
```
```bash
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER ';' NULL 'NULL' CSV HEADER;"
```
```bash
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER '&' NULL '' CSV HEADER;"
```

### Via vacuumdb, VACUUM e ANALYZE em BANCO determinado, completo:

```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -z
```

#### Via vacuumdb, VACUUM e "posteriormente", ANALYZE em BANCO/TABELA determinada:

```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -t public.TABELA
```
```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -Z -t public.TABELA
```
### Via vacuumdb, VACUUM "E" ANALYZE em tabela determinada:

```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -Z -t public.TABELA
```

### Via reindexdb, REINDEX em BANCO determinado, completo:

```bash
reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v
```
### Via reindexdb, REINDEX em BANCO/TABELA determinado:

```BASH
reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -t public.TABELA
```
