# Dump de banco export e import de tabelas em csv (POSTGRESQL)

Deve instalar o pacote **git** e **logar** como **postgres**.  
Para logar como postgres, se tiver acesso ao root, logue com o mesmo e faça:

```bash
su - postgres
```
Se não tiver acesso como root mas tiver o sudo, faça:

```bash
sudo su - postgres
```

## Obter Script upsert

```bash
git clone https://github.com/elppans/pgsql_csv-export-upsert.git
```
```bash
cd pgsql_csv-export-upsert/
```
## Configurar arquivos de variáveis

Configure o **BANCO ATUAL** no arquivo para **EXPORTAR** e o **BANCO NOVO** no arquivo para **IMPORTAR**.  
>Preencha o restante das informações também.  

```
nano banco_psql_export.env
```
```bash
nano banco_psql_import.env
```

Faça backup dos arquivos após configurar

```bash
cp -av banco_psql_export.env banco_psql_export.env.backup
```
```bash
cp -av banco_psql_import.env banco_psql_import.env.backup
```

## Listar e Criar novo banco:

```bash
psql -l | cat
```
```bash
createdb BancoNOVO
```

## Exportar Dump "somente esquema" do Banco ANTIGO para `.dmp.gz`

```bash
./Dump_export-schema-only.sh
```
##  Importar Dump para o "BANCO NOVO"

```bash
./Dump_import.sh Arquivo_Dump.dmp.gz
```

## Tabelas

Deve configurar um arquivo com o nome tabelas.txt com uma lista de tabelas a exportar. Uma tabela por linha.  
Exemplo:  

```ini
tabela_1
tabela_2
...
```

## Completar tabelas dependentes

Após configurar o arquivo tabelas.txt, execute este próximo Script para que seja verificado as tabelas dependentes e complete em uma nova lista.  
>Se estiver usando o arquivo [tabelas_full_nozan.txt](https://github.com/elppans/sh-bd/blob/main/tabelas_full_nozan.txt), pode pular para o próximo item.  

```bash
./tabelas_ordenadas_completas.sh
```

Após terminar a execução, deve fazer backup do original e substituir pela nova lista.  

```bash
cp -a tabelas.txt tabelas.txt.backup
```
```bash
cat ./tabelas_ordenadas_completas.txt >tabelas.txt
```

## Exportar CSVs e importar

Exporte os CSVs, faça um teste para ter certeza e finalmente importe para o novo banco.  
```
./CSV_export.sh
```
```bash
./CSV_import-teste.sh tab_loja tab_loja.csv
```
```bash
./CSV_import-upsert-full.sh
```

## Renomear Bancos

Se achar necessário, renomeie o Banco novo pra algum outro nome
```bash
psql  -p 5432 -U postgres -c "ALTER DATABASE \"BancoNOVO\" RENAME TO \"BancoRENOMEADO\""
```
## Criar Backup do banco "NOVO"

Após importar os CSVs, se forem bem sucedidos, não esquecer de criar um novo backup.  
Pode usar esta variavel de versão para versionar o banco ou digitar o número direto. É sua preferencia.  

```bash
VERSAO="$(psql -d BancoNOVO -c "select * from tab_controle_versao" | grep '2.14' | awk '{print $3}')"
```

Finalmente, o backup  

- Método 1:
```bash
pg_dump --verbose --no-owner --no-acl --inserts -d BancoNOVO | gzip > "$HOME/BancoNOVO_"$VERSAO"_"$(date +%Y%m%d%H%M)".dmp.gz"
```
- Método 2:
```bash
```
