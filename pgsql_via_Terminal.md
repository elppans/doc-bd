#	Comandos pgsql via Terminal:

### Criar um Super Usuário no Banco:

```bash
psql -p 5432 -U postgres -c "CREATE USER NOMEUSUARIO SUPERUSER INHERIT CREATEDB CREATEROLE" -d template1
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



### Exportar Select para CSV:

```bash
psql -p 5432 -d NOMEBANCO -U postgres -c "\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv"
```



#### Exportar Select para CSV usando delimitadores:

```bash
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv HEADER"
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ',' HEADER"
"\copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' with csv DELIMITER ';' HEADER"
"copy (SELECT * FROM TABELA) to '/opt/arquivo.CSV' (DELIMITER ';');"
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER ';' NULL 'NULL' CSV HEADER;"
"COPY TABELA TO '/opt/arquivo.CSV' DELIMITER '&' NULL '' CSV HEADER;"


```

### Via vacuumdb, VACUUM e ANALYZE em BANCO determinado, completo:

```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -z
```

### Via reindexdb, REINDEX em BANCO determinado, completo:

```bash
echo -e "REINDEXANDO BANCO...\n" && sleep 5
reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v
echo -e "REINDEX TERMINADO\n"
```
