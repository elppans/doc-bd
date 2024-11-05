# PostgreSQL no Ubuntu (22.04)

Será configurado o **PostgreSQL** do **repositório** oficial do Ubuntu (**Security**)

## Configurando locales para ISO-8859-1:

## Configurar o locale.alias

```bash
sudo cp -av /etc/locale.alias /etc/locale.alias.bkp
```

```bash
echo -e 'pt_BR pt_BR.ISO-8859-1' | sudo tee -a /etc/locale.alias
```

```bash
grep pt /etc/locale.alias
```

## Configurar locale.gen

```bash
sudo sed -i '/pt_BR ISO-8859-1/s/#//' /etc/locale.gen
```

```bash
grep pt /etc/locale.gen
```

```bash
sudo locale-gen
```

## Atualize os repositórios

```bash
sudo apt update
```

# Instalar PostgreSQL 14:

```bash
sudo apt -y install postgresql-14
```

Verificar se a versão foi instalada corretamente e se está aceitando conexões

```bash
psql --version
```

```bash
pg_isready
```

### Configurar banco para usar ISO-88591 (LATIN1)

```bash
sudo pg_ctlcluster 14 main stop
```

```bash
sudo pg_dropcluster 14 main
```

```bash
sudo pg_createcluster --locale=pt_BR.iso88591 -e LATIN1 14 main
```

```bash
sudo pg_ctlcluster 14 main start
```

### Alterar arquivo pg_hba.conf

- Edição manual do pg_hba.conf:

Edite o arquivo `/etc/postgresql/{VERSAO DO POSTGRES}/main/pg_hba.conf` e adicione no final do arquivo o IP 0.0.0.0 e o IP do servidor para que seja liberado a comunicação do Manager com o banco:

```ini
host all all 0.0.0.0/0 trust
host all all 192.168.15.90/24 trust
```

### Alterar arquivo postgresql.conf

- Edição manual do arquivo postgresql.conf:  

Edite o arquivo `/etc/postgresql/{VERSAO DO POSTGRES}/main/postgresql.conf` e ache a linha com `listen_addresses`, descomente e deixe desta forma:  

```ini
listen_addresses = '*'  
```

Ache a linha que tem ``port = 5432`` e se estiver comentado, descomente.  
Depois salve e saia do editor.  

Reiniciar o PostgreSQL

```bash
sudo systemctl restart postgresql
```

```bash
systemctl status postgresql
```

Modificar senha do usuario postgres no template

```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

Ubuntu nega o uso do usuário postgres, então deve criar outro usuário para poder fazer tarefas administrativas  

```bash
sudo -u postgres createuser -d -l -P -r -s --replication pgadmin
```

Criar um banco para uso. Exemplo, com o nome do host

```bash
createdb -h127.0.0.1 -p 5432 -U pgadmin db.`hostname` db.`hostname`
```

Listar bancos

```bash
psql -h127.0.0.1 -p 5432 -U pgadmin -l
```

Adicionar "Funções" no Banco

```bash
wget -c https://raw.githubusercontent.com/elppans/zretail/master/function.sql
```

```bash
psql -h127.0.0.1 -p 5432 -d db.`hostname` -U pgadmin -W -f function.sql
```

# Liberar portas, Firewall UFW

- **(Em edição)**

- Fontes:

[postgresql, Linux downloads (Ubuntu)](https://www.postgresql.org/download/linux/ubuntu/)  
[postgresql, Linux downloads (Debian)](https://www.postgresql.org/download/linux/debian/)  
[postgresql, Linux downloads (Red Hat)](https://www.postgresql.org/download/linux/redhat/)  
[Archlinux PostgreSQL 10, AUR](https://aur.archlinux.org/packages/postgresql-10)  
[Wikipédia, ISO/IEC 8859-1](https://pt.wikipedia.org/wiki/ISO/IEC_8859-1)  

- Mais fontes:

[Debian Firmware](https://wiki.debian.org/Firmware)  
[Debian "non-free", CD including firmware](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/11.3.0+nonfree/amd64/iso-cd/)  
[Sites-espelho mundiais do Debian](https://www.debian.org/mirror/list)  
[Alias de espelho Debian BR](/tmp/.mount_joplinAUlfvv/resources/app.asar/ftp.br.debian.org/debian/ "ftp.br.debian.org/debian/")  
[Debian Security](https://www.debian.org/security/)  
[Debian LTS - pt_BR](https://wiki.debian.org/pt_BR/LTS)  
[Debian LTS/Using](https://wiki.debian.org/LTS/Using)  
[Introdução ao Empacotamento Debian](https://wiki.debian.org/pt_BR/Packaging/Intro)  
[Chapter 7. Basics of the Debian package management system](https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html)  
[Chapter 8. The Debian package management tools](https://www.debian.org/doc/manuals/debian-faq/pkgtools.en.html)  
[pt_BR How To Package For Debian](https://wiki.debian.org/pt_BR/HowToPackageForDebian)  
[Debian/Ubuntu, Find Out What Package Provides a File](https://www.cyberciti.biz/faq/equivalent-of-rpm-qf-command/)  
[How to Find the Debian Package that Provides a File](https://linuxhint.com/find-debian-package-provides-file/)  
[Debian NetworkManager, Wiki](https://wiki.debian.org/pt_BR/NetworkManager)  
[NetworkManager (NMCLI) on Ubuntu/Debian](https://computingforgeeks.com/install-and-use-networkmanager-nmcli-on-ubuntu-debian/)  
[Configurar IP com 'nmtui'](https://pt.linux-console.net/?p=447)  
[No nmtui/nmcli on freshly install Debian](https://www.reddit.com/r/debian/comments/qb7vjj/no_nmtuinmcli_on_freshly_install_debian_standard/)  
[Debian Locale](https://wiki.debian.org/pt_BR/Locale)  
[Configurar locales de UTF8 para ISO88591](https://www.vivaolinux.com.br/dica/Reconfigurar-as-LOCALES-passando-de-UTF8-para-ISO88591)  
[dpkg-reconfigure locales](https://askubuntu.com/questions/683406/how-to-automate-dpkg-reconfigure-locales-with-one-command)  
[Falha de autenticação postgres PGSQL 11](https://stackoverflow.com/questions/55038942/fatal-password-authentication-failed-for-user-postgres-postgresql-11-with-pg)  

[PSQL Fatall authentication](https://stackoverflow.com/questions/17443379/psql-fatal-peer-authentication-failed-for-user-dev)
[Debian PostgreSQL](https://wiki.postgresql.org/wiki/Apt)
