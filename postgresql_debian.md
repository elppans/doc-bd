# PostgreSQL no Debian

## Instalar gerenciador de rede e configurar IP

```
sudo apt update && sudo apt upgrade
sudo apt -y install network-manager
sudo mv /etc/network/interfaces /etc/network/interfaces.old
sudo systemctl restart networking
sudo systemctl restart NetworkManager
```

## Configurar, desativar, ativar rede

```
sudo nmtui
sudo systemctl restart NetworkManager
```

## Configurando locales para ISO-8859-1:

## Configurar o locale.alias

```
sudo cp -av /etc/locale.alias /etc/locale.alias.bkp
echo -e 'pt_BR pt_BR.ISO-8859-1' | sudo tee -a /etc/locale.alias
grep pt /etc/locale.alias
```

## Configurar locale.gen

```
sudo sed -i '/pt_BR ISO-8859-1/s/#//' /etc/locale.gen
grep pt /etc/locale.gen
sudo locale-gen
```
>Sempre verificar após uma atualização, se o arquivo `/etc/locale.gen`foi sobrescrito.  
>Caso a linha `pt_BR ISO-8859-1` estiver comentada, faça o `sed` novamente para descomentar.  

## Instalar certificados e repositório PostgreSQL:

```
sudo apt -y install curl ca-certificates gnupg
```

### Criar a configuração do repositório de arquivos

```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

### Importar a chave de assinatura do repositório

```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```

Se usando o apt-key não der certo, faça este comando

```
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
```

Atualize os repositórios

```
sudo apt update
```

# Instalar PostgreSQL 16:

```
sudo apt -y install postgresql-16
```

Verificar se a versão foi instalado corretamente e se está aceitando conexões

```
psql --version
pg_isready
```

### Configurar banco para usar ISO-88591 (LATIN1)

```
sudo pg_ctlcluster 16 main stop
sudo pg_dropcluster 16 main
sudo pg_createcluster --locale=pt_BR.iso88591 -e LATIN1 16 main
sudo pg_ctlcluster 16 main start
```

### Alterar arquivo pg_hba.conf

```
PGDATA="/var/lib/postgresql/16/main"
export IPROUTE=$(ip route show | grep kernel | awk '{ print $1 }' | head -1)
echo -e "\nhost all all 0.0.0.0/0 trust\n" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo -e "\nhost all all "$IPROUTE" trust\n" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
```
- Edição manual do pg_hba.conf:
  
Edite o arquivo /etc/postgresql/{VERSAO DO POSTGRES}/main/pg_hba.conf e adicione no final do arquivo o IP 0.0.0.0 e o IP do servidor para que seja liberado a comunicação do Manager com o banco:

```
host all all 0.0.0.0/0 trust
host all all 192.168.15.90/24 trust
```

### Alterar arquivo postgresql.conf

```
sudo sed -i '/listen_addresses/s/#//' /etc/postgresql/16/main/postgresql.conf
sudo sed -i '/listen_addresses/s/localhost/*/' /etc/postgresql/16/main/postgresql.conf
sudo sed -i "s/^#*\(port = \).*/\15432/" /etc/postgresql/16/main/postgresql.conf
```

- Edição manual do arquivo postgresql.conf:  

Ache a linha com `listen_addresses`, descomente e deixe desta forma:  

```
listen_addresses = '*'  
```
Ache a linha que tem ``port = 5432`` e se estiver comentado, descomente.  
Depois salve e saia do editor.  

Reiniciar o PostgreSQL

```
sudo systemctl restart postgresql
systemctl status postgresql
```
>>`systemctl status postgresql@16-main.service`  
>
>Também pode ser necessário verificar os logs do postgresql:  
>>`sudo tail -n 50 /var/log/postgresql/postgresql-16-main.log`  
>
>Para saber mais, veja [Diferenças dos status postgresql](https://elppans.github.io/doc-bd/status_postgresql)  

Modificar senha do usuario postgres no template

```
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

Debian nega o uso do usuário postgres, então deve criar outro usuário para poder fazer tarefas administrativas  

```
sudo -u postgres createuser -d -l -P -r -s --replication pgadmin
```

Criar um banco para uso. Exemplo, com o nome do host

```
createdb -h127.0.0.1 -p 5432 -U pgadmin db.`hostname` db.`hostname`
```

Listar bancos

```
psql -h127.0.0.1 -p 5432 -U pgadmin -l
```

Adicionar "Funções" no Banco

```
wget -c https://raw.githubusercontent.com/elppans/doc-bd/refs/heads/main/function.sql
psql -h127.0.0.1 -p 5432 -d db.`hostname` -U pgadmin -W -f function.sql
```

# Liberar portas, FirewallD

Usando FirewallD, pode ser usado o nome do serviço ou diretamente a porta para a liberação  
Deve instalar o pacote do FirewallD para poder usar

```
sudo apt -y install firewalld
sudo systemctl enable --now firewalld
systemctl status firewalld
```

Liberando a PostgreSQL usando serviço

```
sudo firewall-cmd --zone=$(firewall-cmd --get-default-zone) --permanent --add-service=postgresql
```

Liberando a PostgreSQL usando a porta

```
sudo firewall-cmd --permanent --add-port=5432/tcp
```

Recarregando as configurações do FirewallD e listando as portas liberadas  

```
sudo firewall-cmd --reload 
sudo firewall-cmd --list-all
```

- Fontes:

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
