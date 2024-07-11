# Diferença entre 2 comandos pg_dump:

1)
```
pg_dump --verbose --host 127.0.0.1 --port 5432 --username postgres --inserts -d ZeusRetail > /opt/DUMP/ZeusRetail_"$(cat /opt/DUMP/vers_db)"_"$date_dump".dmp
```

2)

```
pg_dump --verbose --host 127.0.0.1 --port 5432 --username postgres --no-owner --no-acl -Fc ZeusRetail > /opt/backup/PRIME_PENALVA_"$date_dump".dump.backup
```

- Resposta:

Claro! Vamos analisar esses dois comandos do `pg_dump` para o PostgreSQL:

1. O primeiro comando:
   
   ```
   pg_dump --verbose --host 127.0.0.1 --port 5432 --username postgres --inserts -d ZeusRetail > /opt/DUMP/ZeusRetail_"$(cat /opt/DUMP/vers_db)"_"$date_dump".dmp
   ```
   
   - Aqui, estamos fazendo um *dump* (backup) da base de dados chamada `ZeusRetail`.
   - As opções utilizadas são:
     - `--verbose`: Exibe informações detalhadas durante o processo.
     - `--host 127.0.0.1`: Especifica o endereço IP do servidor PostgreSQL (localhost neste caso).
     - `--port 5432`: Define a porta do servidor PostgreSQL.
     - `--username postgres`: Indica o usuário para autenticação.
     - `--inserts`: Gera comandos `INSERT` para os dados.
     - `-d ZeusRetail`: Especifica o nome da base de dados.
   - O resultado é redirecionado para o arquivo `/opt/DUMP/ZeusRetail_"$(cat /opt/DUMP/vers_db)"_"$date_dump".dmp`.

2. O segundo comando:
   
   ```
   pg_dump --verbose --host 127.0.0.1 --port 5432 --username postgres --no-owner --no-acl -Fc ZeusRetail > /opt/backup/PRIME_PENALVA_"$date_dump".dump.backup
   ```
   
   - Aqui, também estamos fazendo um *dump* da base de dados `ZeusRetail`.
   - As opções utilizadas são:
     - `--no-owner`: Não inclui informações sobre proprietários de objetos.
     - `--no-acl`: Ignora as permissões de acesso (ACL).
     - `-Fc`: Formato de saída personalizado (compactado).
   - O resultado é redirecionado para o arquivo `/opt/backup/PRIME_PENALVA_"$date_dump".dump.backup`.

Em resumo, o primeiro comando gera um *dump* com comandos `INSERT` e inclui informações sobre proprietários e permissões. O segundo comando não inclui essas informações e usa um formato compactado. 

Fontes:
1. [pg_dump: aborting because of server version mismatch.](https://stackoverflow.com/questions/45051633/pg-dump-aborting-because-of-server-version-mismatch)
2. [PostgreSQL: Could not connect to server: TCP/IP connections on port 5432](https://stackoverflow.com/questions/55326804/postgresql-could-not-connect-to-server-tcp-ip-connections-on-port-5432)
3. [Como realizar Backup de uma base de dados PostgreSQL através do pgAdmin...](https://pt.stackoverflow.com/questions/168698/como-realizar-backup-de-uma-base-de-dados-postgresql-atrav%C3%A9s-do-pgadmin-4)

