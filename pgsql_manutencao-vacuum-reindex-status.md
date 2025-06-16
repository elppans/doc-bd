 # Processos de `VACUUM` e `REINDEX`
 
No PostgreSQL, você pode verificar se os processos de `VACUUM` e `REINDEX` estão sendo executados usando consultas na visão `pg_stat_activity`. Aqui estão alguns comandos úteis:

Para verificar se há um processo de `VACUUM` em execução:
```sql
SELECT pid, query, state 
FROM pg_stat_activity 
WHERE query LIKE 'VACUUM%';
```

Para verificar se há um processo de `REINDEX` em execução:
```sql
SELECT pid, query, state 
FROM pg_stat_activity 
WHERE query LIKE 'REINDEX%';
```

Se quiser um panorama mais detalhado sobre atividades de manutenção, o comando abaixo pode ser útil:
```sql
SELECT * FROM pg_stat_progress_vacuum;
```
Ele fornece estatísticas sobre um `VACUUM` em progresso, incluindo a tabela sendo processada e a quantidade de páginas analisadas.

Se estiver utilizando o `autovacuum`, pode verificar se ele está ativo com:
```sql
SELECT * FROM pg_stat_activity WHERE query LIKE '%autovacuum%';
```
___
# Interromper um processo de VACUUM

Para interromper um processo de `VACUUM` em execução no PostgreSQL, você pode usar o comando `pg_terminate_backend(pid)`, onde `pid` é o identificador do processo em execução. Primeiro, localize o `PID` do processo de `VACUUM` com:

```sql
SELECT pid, query 
FROM pg_stat_activity 
WHERE query LIKE 'VACUUM%';
```

Depois, interrompa o processo com:

```sql
SELECT pg_terminate_backend(pid);
```

**Atenção:** O uso de `pg_terminate_backend()` pode afetar a integridade das operações em andamento, então avalie bem antes de forçar a interrupção. Se for um `autovacuum`, ele pode ser reiniciado automaticamente mais tarde.
___
## Resumo, somente comandos

- Status
```bash
psql -U postgres -c "SELECT pid, query, state FROM pg_stat_activity WHERE query LIKE 'VACUUM%';"
psql -U postgres -c "SELECT pid, query, state FROM pg_stat_activity WHERE query LIKE 'REINDEX%';"
psql -U postgres -c "SELECT * FROM pg_stat_progress_vacuum;"
psql -U postgres -c "SELECT * FROM pg_stat_activity WHERE query LIKE '%autovacuum%';"
```
- Kill PID
```bash
psql -U postgres -c "SELECT pid, query FROM pg_stat_activity WHERE query LIKE 'VACUUM%';"
psql -U postgres -c "SELECT pg_terminate_backend(pid);"
```
```bash
psql -U postgres -c "SELECT pid, query FROM pg_stat_activity WHERE query LIKE 'REINDEX%';"
psql -U postgres -c "SELECT pg_terminate_backend(pid);"
```

