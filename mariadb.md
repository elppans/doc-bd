# Instalar Servidor MariaDB

Este documento fornece um guia para instalar e configurar o servidor MariaDB.

## Passos para Instalação

### 1. Baixar o MariaDB
```bash
cd ~/Downloads
wget -c https://espejito.fder.edu.uy/mariadb///mariadb-11.8.0/bintar-linux-systemd-x86_64/mariadb-11.8.0-preview-linux-systemd-x86_64.tar.gz
```

### 2. Criar grupo e usuário MySQL
```bash
sudo groupadd mysql
sudo useradd -g mysql mysql
```

### 3. Extrair e configurar o MariaDB
```bash
cd /usr/local
sudo tar -xvf /home/suporte4/Downloads/mariadb-11.8.0-preview-linux-systemd-x86_64.tar.gz
sudo unlink /usr/local/mysql
sudo ln -s mariadb-11.8.0-preview-linux-systemd-x86_64 mysql

cd mysql
sudo chown -R mysql .
sudo chgrp -R mysql .
sudo scripts/mysql_install_db --user=mysql
sudo chown -R root .
sudo chown -R mysql data
sudo bin/mysqld_safe --user=mysql &
sudo ln -sf /usr/local/mysql/bin/* /usr/local/bin
```

## Configuração do Usuário MySQL

### 1. Criar senha para o usuário MySQL
Conecte-se ao MariaDB como root ou um usuário existente com permissões:
```bash
sudo mysql -u root -p
```

Liste os usuários do banco:
```sql
SELECT User, Host FROM mysql.user;
```

Defina a nova senha para um usuário específico (Exemplo):
```sql
SET PASSWORD FOR 'mysql'@'localhost' = PASSWORD('mysql');
```

### 2. Criar um novo usuário
Depois de conectado, crie um novo usuário (exemplo):
```sql
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
```

Conceda todos os privilégios ao novo usuário:
```sql
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
```

Atualize os privilégios:
```sql
FLUSH PRIVILEGES;
```

## Comandos úteis

### 1. Listar os bancos
```sql
SHOW DATABASES;
```

### 2. Criar um novo banco
```sql
CREATE DATABASE db_local;
```

### 3. Remover um banco específico
```sql
DROP DATABASE nome_do_banco;
```

### 4. Sair do servidor MariaDB
Para sair:
```bash
exit;
# ou
quit;
```

## Consultas e Gerenciamento de Privilégios

### 1. Listar usuários e seus privilégios
Exibe uma lista detalhada de todos os privilégios concedidos ao usuário atual:
```sql
SHOW GRANTS;
```

Listar os privilégios de um usuário específico:
```sql
SHOW GRANTS FOR 'nome_do_usuario'@'host';
```

Para uma visualização formatada:
```sql
SHOW GRANTS FOR 'meu_usuario'@'%' \G;
```

### 2. Listar todos os usuários
Consulte a tabela `mysql.user`:
```sql
SELECT User, Host, Password FROM mysql.user;
```

### 3. Alterar os privilégios de um usuário
Para revogar todos os privilégios de um usuário:
```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'meu_usuario'@'%';
```

---
**Observações:**
- Certifique-se de manter as credenciais seguras.
- Consulte a documentação oficial do MariaDB para recursos avançados.
___

- Fontes:  
https://mariadb.com/kb/en/where-to-download-mariadb/

- Pacote compilado:  
https://mariadb.org/download/

- Source:  
https://github.com/MariaDB/server  
https://github.com/MariaDB/server/archive/refs/tags/mariadb-11.6.2.tar.gz  
https://aur.archlinux.org/packages/mariadb-git  

- Instruções para compilar MariaDB:  
https://mariadb.com/kb/en/compiling-mariadb-from-source

