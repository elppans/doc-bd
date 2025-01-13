Instalar Servidor MariaDB

https://mariadb.com/kb/en/where-to-download-mariadb/

Pacote compilado::
https://mariadb.org/download/

Source:
https://github.com/MariaDB/server
https://github.com/MariaDB/server/archive/refs/tags/mariadb-11.6.2.tar.gz
https://aur.archlinux.org/packages/mariadb-git

Instructions for building MariaDB can be found at:
https://mariadb.com/kb/en/compiling-mariadb-from-source

___

Instalar Servidor MariaDB versão Binário
```
cd ~/Downloads
```
```
wget -c https://espejito.fder.edu.uy/mariadb///mariadb-11.8.0/bintar-linux-systemd-x86_64/mariadb-11.8.0-preview-linux-systemd-x86_64.tar.gz
```
```
sudo groupadd mysql
```
```
sudo useradd -g mysql mysql
```
```
cd /usr/local
```
```
sudo tar -xvf /home/suporte4/Downloads/mariadb-11.8.0-preview-linux-systemd-x86_64.tar.gz
```
```
sudo unlink /usr/local/mysql
```
```
sudo ln -s mariadb-11.7.1-linux-systemd-x86_64 mysql
```
```
cd mysql
```
```
sudo chown -R mysql .
```
```
sudo chgrp -R mysql .
```
```
sudo scripts/mysql_install_db --user=mysql
```
```
sudo chown -R root .
```
```
sudo chown -R mysql data
```
```
sudo bin/mysqld_safe --user=mysql &
```
```
ps ax | grep mysql | grep -v grep
```

## Criar senha para o usuário mysql

- Conecte-se ao MariaDB como root ou um usuário existente com permissões:

```
 sudo ./mysql -u root -p
```
 - Listar os usuários do banco:
 ```
 SELECT User, Host FROM mysql.user;
```
- use o comando abaixo para definir a nova senha para um usuário específico (Exemplo):
```
SET PASSWORD FOR 'mysql'@'localhost' = PASSWORD('mysql');
```
## Criar um novo usuário:

- Depois de conectado, crie um novo usuário (exemplo):
```
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
```
- Conceda todos os privilégios ao novo usuário:
```
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
```
- Atualize os privilégios:
```
FLUSH PRIVILEGES;
```
## Listar os bancos
```
SHOW DATABASES;
```
## Criar um banco novo
```
CREATE DATABASE db_local;
```
## Remover um banco especifico
```
DROP DATABASE nome_do_banco;
```
## Sair do servidor MariaDB

Basta digitar:
```
exit;
```
OU
```
quit;
```
___

Script mariadb-server.sh
```
#!/bin/bash

cd /usr/local/mariadb-11.7.1-linux-systemd-x86_64/bin
ps aux | grep mysql && \
echo OK || \
sudo bin/mysqld_safe --user=mysql & 
```
___

Resposta do comando ps, para verificar os processos:

❯ ps aux | grep mysql
root       27219  0.0  0.0  18368  7540 pts/5    SN   12:34   0:00 sudo bin/mysqld_safe --user=mysql
root       27225  0.0  0.0  18368  2644 pts/6    SNs+ 12:34   0:00 sudo bin/mysqld_safe --user=mysql
root       27226  0.0  0.0   7720  3800 pts/6    SN   12:34   0:00 /bin/sh bin/mysqld_safe --user=mysql
mysql      27298  1.1  1.4 1144852 116856 pts/6  SNl  12:34   0:33 /usr/local/mariadb-11.6.2-linux-systemd-x86_64/bin/mariadbd --basedir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64 --datadir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/data --plugin-dir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/lib/plugin --user=mysql --log-error=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/data/pdvtecs4.err --pid-file=pdvtecs4.pid
suporte4   31596  0.0  0.0   6420  2300 pts/7    S<+  13:23   0:00 grep mysql


❯ ps aux | grep mariadb
mysql      27298  1.0  1.4 1144852 116856 pts/6  SNl  12:34   0:33 /usr/local/mariadb-11.6.2-linux-systemd-x86_64/bin/mariadbd --basedir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64 --datadir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/data --plugin-dir=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/lib/plugin --user=mysql --log-error=/usr/local/mariadb-11.6.2-linux-systemd-x86_64/data/pdvtecs4.err --pid-file=pdvtecs4.pid
suporte4   31693  0.0  0.0   6420  2364 pts/7    S<+  13:25   0:00 grep mariadb

sudo kill -9 $(ps ax | grep mysql | grep -v kate | grep -v grep | awk '{print $1}')

#############################################################################################

scripts/mysql_install_db: Deprecated program name. It will be removed in a future release, use 'mariadb-install-db' instead
Installing MariaDB/MySQL system tables in './data' ...
OK

To start mariadbd at boot time you have to copy
support-files/mariadb.service to the right place for your system


Two all-privilege accounts were created.
One is root@localhost, it has no password, but you need to
be system 'root' user to connect. Use, for example, sudo mysql
The second is mysql@localhost, it has no password either, but
you need to be the system 'mysql' user to connect.
After connecting you can set the password, if you would need to be
able to connect as any of these users with a password and without sudo

See the MariaDB Knowledgebase at https://mariadb.com/kb

You can start the MariaDB daemon with:
cd '.' ; ./bin/mariadbd-safe --datadir='./data'

You can test the MariaDB daemon with mariadb-test-run.pl
cd './mariadb-test' ; perl mariadb-test-run.pl

Please report any problems at https://mariadb.org/jira

The latest information about MariaDB is available at https://mariadb.org/.

Consider joining MariaDB's strong and vibrant community:
https://mariadb.org/get-involved/

╰─ bin/mysqld_safe: Deprecated program name. It will be removed in a future release, use 'mariadbd-safe' instead
250110 13:28:27 mysqld_safe Logging to '/usr/local/mariadb-11.8.0-preview-linux-systemd-x86_64/data/pdvtecs4.err'.
250110 13:28:27 mysqld_safe Starting mariadbd daemon with databases from /usr/local/mariadb-11.8.0-preview-linux-systemd-x86_64/data

