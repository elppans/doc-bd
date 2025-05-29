# VACUUM e REINDEX  

- vacuumdb, VACUUM e ANALYZE em BANCO determinado, completo:  
```bash
vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -z
```

- reindexdb, REINDEX em BANCO determinado, completo:  
```bash 
reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v
```

- Uma breve explicação de cada comando:  

1. **VACUUM e ANALYZE**:  
   ```bash
   vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -f -z
   ```
   - `-h 127.0.0.1`: Especifica o host (localhost).  
   - `-p 5432`: Porta do PostgreSQL.  
   - `-U postgres`: Usuário do PostgreSQL.  
   - `-w`: Não solicitar senha.  
   - `-d NOMEBANCO`: Nome do banco de dados.  
   - `-v`: Modo verboso.  
   - `-f`: VACUUM FULL, que reescreve as tabelas.  
   - `-z`: ANALYZE, que atualiza as estatísticas do banco de dados.  

2. **REINDEX**:  
   ```bash
   reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v
   ```
   - `-h 127.0.0.1`: Especifica o host (localhost).  
   - `-p 5432`: Porta do PostgreSQL.  
   - `-U postgres`: Usuário do PostgreSQL.  
   - `-w`: Não solicitar senha.  
   - `-d NOMEBANCO`: Nome do banco de dados.  
   - `-v`: Modo verboso.  

Esses comandos são úteis para manter a performance e a integridade do banco de dados.  

## Otimização  

É possível otimizar os comandos para que não utilizem tantos recursos do sistema. Aqui estão algumas sugestões:  

1. **VACUUM sem FULL**:  
   ```bash
   vacuumdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -z
   ```
   - Removendo a opção `-f` (FULL), o VACUUM será menos intensivo, pois não reescreverá as tabelas inteiras.  

2. **REINDEX de forma seletiva**:  
   Em vez de reindexar todo o banco de dados, você pode reindexar apenas tabelas ou índices específicos:  
   ```bash
   reindexdb -h 127.0.0.1 -p 5432 -U postgres -w -d NOMEBANCO -v -t NOMEDATABELA
   ```
   - A opção `-t NOMEDATABELA` permite especificar uma tabela específica para reindexar, reduzindo a carga no sistema.  

Essas modificações devem ajudar a reduzir o uso de recursos durante a manutenção do banco de dados.  

