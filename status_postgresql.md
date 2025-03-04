# Diferenças dos status postgresql

A diferença entre os comandos "systemctl status postgresql@14-main.service" e "systemctl status postgresql" está na especificidade do serviço que você está verificando.

1. **`systemctl status postgresql`**:
   Esse comando exibe o status do serviço genérico do PostgreSQL. No entanto, como você pode ter várias instâncias (ou versões) do PostgreSQL instaladas no seu sistema, esse comando pode não fornecer informações detalhadas sobre uma instância específica.

2. **`systemctl status postgresql@14-main.service`**:
   Esse comando é mais específico. Ele verifica o status do serviço PostgreSQL versão 14, instância "main". Isso significa que você está consultando diretamente o serviço da versão e instância específica do PostgreSQL, o que resulta em informações mais detalhadas e precisas sobre o status desse serviço em particular.

Usar o comando mais específico (`systemctl status postgresql@14-main.service`) é útil quando você está trabalhando com várias versões ou instâncias do PostgreSQL, pois ajuda a isolar e identificar problemas com precisão.

___

## Descobrir a versão e as instâncias do PostgreSQL

Para descobrir a versão e as instâncias do PostgreSQL instaladas seu sistema, pode ser feito de algumas maneiras:

1. **Usando o comando `pg_lsclusters`**:
   No Debian, o comando `pg_lsclusters` pode listar todas as instâncias do PostgreSQL e suas versões instaladas:
   ```bash
   sudo pg_lsclusters
   ```

   A saída será algo como:
   ```plaintext
   Ver Cluster Port Status Owner    Data directory               Log file
   13  main    5432 online postgres /var/lib/postgresql/13/main  /var/log/postgresql/postgresql-13-main.log
   14  main    5433 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
   ```

2. **Verificando a versão do PostgreSQL usando `psql`**:
   Você pode conectar-se a uma instância do PostgreSQL e verificar a versão diretamente:
   ```bash
   sudo -u postgres psql -c "SELECT version();"
   ```

   Isso retornará algo como:
   ```plaintext
   PostgreSQL 14.2 (Debian 14.2-1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
   ```

3. **Verificando o arquivo de configuração**:
   No Debian, os arquivos de configuração do PostgreSQL geralmente estão localizados em `/etc/postgresql/`. Você pode listar os diretórios para ver quais versões estão instaladas:
   ```bash
   ls /etc/postgresql/
   ```

   A saída será algo como:
   ```plaintext
   13  14
   ```

4. **Verificando os serviços do PostgreSQL**:
   Você pode listar todos os serviços do PostgreSQL que estão configurados no `systemd`:
   ```bash
   sudo systemctl list-units | grep postgresql
   ```

   Isso mostrará algo como:
   ```plaintext
   postgresql@13-main.service                    loaded active running PostgreSQL Cluster 13-main
   postgresql@14-main.service                    loaded active running PostgreSQL Cluster 14-main
   ```
