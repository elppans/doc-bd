#	Comandos pgsql via Terminal:

### Select para Verificar a versão do PostgreSQL

```sql
SELECT version();
```
___

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
___

### Listar bancos:

```bash
psql  -p 5432 -U postgres -l
```

### Criar banco:

```bash
createdb -U postgres NOMEBANCO NOMEBANCO
```
___

### Criar banco, com Encoding `LATIN1`, Collate/CType `ISO8859-1`:  

```bash
createdb -U postgres -E LATIN1 --locale=pt_BR.iso88591 -T template0 NOMEBANCO
```

### Criar banco especificando Encoding no Windows

**Windows-1252 (WIN1252)** é uma **superset** de **ISO-8859-1 (LATIN1)**
Todos os caracteres de **ISO-8859-1** estão presentes em **WIN1252**
**WIN1252** inclui alguns caracteres extras nos códigos **0x80–0x9F** `(como € e ‘ ’ “ ”)`

```bash
createdb -U postgres -E WIN1252 --locale=Portuguese_Brazil.1252 -T template0 NOMEBANCO
```

___

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
___
### Executar comandos no psql:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "COMANDO"
```
### Desconectar todos os usuários de um banco específico:
```bash
psql -d NOMEBANCO -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'NOMEBANCO' AND pid <> pg_backend_pid();"
```
___
### Verificar tamanho do Banco, em bytes:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "select pg_database_size('NOMEBANCO');"
```

### Verificar tamanho do banco
> Equivalente ao du -sh * na pasta base:  

##### Database Size: 

```sql
SELECT pg_size_pretty(pg_database_size('Database Name'));
```

##### Table Size:

```sql
SELECT pg_size_pretty(pg_relation_size('table_name'));
```

### Tamanho TODAS as tabelas do banco, em ordem de tamanho, do maior pro menor

```sql
SELECT table_name AS "NomeTabela",
       pg_size_pretty(pg_total_relation_size('"' || table_name || '"')) AS "Tamanho"
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size('"' || table_name || '"') DESC;
```
### União entre "Verificar tamanho do banco" e "Tamanho TODAS as tabelas do banco"
>Colunas: Nome, Tamanho (Eq. du -sh) e Tamanho em Bytes (Eq. du -s)

```sql
-- Tamanho do Banco
select datname AS "Nome", 
  pg_size_pretty(pg_database_size(datname)) AS "Tamanho",
  pg_database_size(datname) AS tamanho_bytes
FROM pg_database
--where datname = 'Banco';
UNION all
-- Tamanho das tabelas 
SELECT table_name AS "Nome",
       pg_size_pretty(pg_total_relation_size('"' || table_name || '"')) AS "Tamanho",
       pg_total_relation_size('"' || table_name || '"') AS tamanho_bytes
FROM information_schema.tables
WHERE table_schema = 'public'
--ORDER BY pg_total_relation_size('"' || table_name || '"') DESC;

-- 3ª Coluna, para unir o Banco e Tabelas, por tamanho em bytes
ORDER BY tamanho_bytes DESC;
```
___

### Tamanho TODAS as tabelas do banco, em ordem de tamanho, do maior pro menor, tabelas de [10+ GB](https://github.com/elppans/doc-linux/blob/main/1024_em_computacao.md)

```sql
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
___
### Exportar Select para CSV:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv"
```

#### Exportar Select para CSV usando delimitadores:

```sql
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv HEADER"
```
```sql
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ',' HEADER"
```
```sql
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ';' HEADER"
```
```sql
"copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' (DELIMITER ';');"
```
```sql
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER ';' NULL 'NULL' CSV HEADER;"
```
```sql
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER '&' NULL '' CSV HEADER;"
```
___
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
