# PostgreSQL no Debian

## Instalar gerenciador de rede e configurar IP (OPCIONAL)

Se durante a instalação do Debian, optou de usar DHCP e tiver a necessidade de configurar um IP fixo, é mais fácil usar o aplicativo do `Network Manager User Interfacec (nmtui)`.  
Se optou por configurar um IP fixo durante a instalação ou não houver necessidade de configurar depois, pule esta etapa para `Configurando locales para ISO-8859-1`.  

```bash
sudo apt update && sudo apt upgrade
```
```bash
sudo apt -y install network-manager
```
```bash
sudo mv /etc/network/interfaces /etc/network/interfaces.old
```
```bash
sudo systemctl restart networking
```
```bash
sudo systemctl restart NetworkManager
```

## Configurar, desativar, ativar rede

```bash
sudo nmtui
```
```bash
sudo systemctl restart NetworkManager
```

## Configurando locales para ISO-8859-1:

O Manager utiliza a codificaçao `LATIN1 (ISO-8859-1)`, então é recomendável não só instalar o banco, mas configurar para que seja usado esta codificão por padrão.  
Para usar a codificação `ISO-8859-1` no banco, deve configurar para que o sistema também use ou tenha suporte, senão não dá pra configurar o banco para esta codificação.  

## Configurar o locale.alias

```bash
sudo cp -av /etc/locale.alias /etc/locale.alias.original
```

```bash
echo -e 'pt_BR pt_BR.ISO-8859-1' | sudo tee -a /etc/locale.alias
```

```bash
grep pt /etc/locale.alias
```

## Configurar locale.gen

```bash
sudo cp -av /etc/locale.gen /etc/locale.gen.original
```

```bash
sudo sed -i '/pt_BR ISO-8859-1/s/#//' /etc/locale.gen
```

```bash
grep pt /etc/locale.gen
```

```bash
sudo localedef -i pt_BR -f ISO-8859-1 pt_BR.ISO-8859-1
```
```bash
locale -a | grep pt_BR
```
```bash
sudo locale-gen
```
## Evitar perder a configuração dos arquivos "locale"

- Use o `dpkg-divert` para que o sistema não sobrescreva seus arquivos durante atualizações

```bash
sudo dpkg-divert --add --rename --divert /etc/locale.alias.real /etc/locale.alias
```
```bash
sudo dpkg-divert --add --rename --divert /etc/locale.gen.real /etc/locale.gen
```

- Replique os arquivos novamente

```bash
sudo cp -a /etc/locale.alias.real /etc/locale.alias
```
```bash
sudo cp -a /etc/locale.gen.real /etc/locale.gen
```

- Comparando os arquivos

```bash
ls -all /etc/locale*
```
>Para mais informações, veja [Ubuntu, arquivos locale customizados](https://github.com/elppans/doc-linux/blob/main/ubuntu_arquivos_locale_customizados.md)  


## Instalar certificados e repositório PostgreSQL:

```bash
sudo apt -y install curl ca-certificates gnupg gnupg2 lsb-release vim nano
```

### Criar a configuração do repositório de arquivos

```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```

### Importar a chave de assinatura do repositório

```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```

Se usando o apt-key não der certo, faça este comando

```bash
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
```

Atualize os repositórios

```bash
sudo apt update
```

# Instalar PostgreSQL 16:

```bash
sudo apt -y install postgresql-16
```

Verificar se a versão foi instalado corretamente e se está aceitando conexões

```bash
psql --version
```
```bash
pg_isready
```

### Configurar banco para usar ISO-88591 (LATIN1)

```bash
sudo pg_ctlcluster 16 main stop
```
```bash
sudo pg_dropcluster 16 main
```
```bash
sudo pg_createcluster --locale=pt_BR.iso88591 -e LATIN1 16 main
```
```bash
sudo pg_ctlcluster 16 main start
```

### Alterar arquivo pg_hba.conf

```bash
PGDATA="/var/lib/postgresql/16/main"
```
```bash
export IPROUTE=$(ip route show | grep kernel | awk '{ print $1 }' | head -1)
```
```bash
echo -e "\nhost all all 0.0.0.0/0 trust\n" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
```
```bash
echo -e "\nhost all all "$IPROUTE" trust\n" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
```
- Edição manual do pg_hba.conf:
  
Edite o arquivo /etc/postgresql/{VERSAO DO POSTGRES}/main/pg_hba.conf e adicione no final do arquivo o IP 0.0.0.0 e o IP do servidor para que seja liberado a comunicação do Manager com o banco:

```ini
host all all 0.0.0.0/0 trust
host all all 192.168.15.90/24 trust
```

### Alterar arquivo postgresql.conf

```bash
sudo sed -i '/listen_addresses/s/#//' /etc/postgresql/16/main/postgresql.conf
```
```bash
sudo sed -i '/listen_addresses/s/localhost/*/' /etc/postgresql/16/main/postgresql.conf
```
```bash
sudo sed -i "s/^#*\(port = \).*/\15432/" /etc/postgresql/16/main/postgresql.conf
```

- Edição manual do arquivo postgresql.conf:  

Ache a linha com `listen_addresses`, descomente e deixe desta forma:  

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
>>`systemctl status postgresql@16-main.service`  
>
>Também pode ser necessário verificar os logs do postgresql:  
>>`sudo tail -n 50 /var/log/postgresql/postgresql-16-main.log`  
>
>Para saber mais, veja [Diferenças dos status postgresql](https://elppans.github.io/doc-bd/status_postgresql)  

Modificar senha do usuario postgres no template

```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

Debian nega o uso do usuário postgres, então deve criar outro usuário para poder fazer tarefas administrativas  

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
wget -c https://raw.githubusercontent.com/elppans/doc-bd/refs/heads/main/function.sql
```
```bash
psql -h127.0.0.1 -p 5432 -d db.`hostname` -U pgadmin -W -f function.sql
```

# Liberar portas, FirewallD

Usando FirewallD, pode ser usado o nome do serviço ou diretamente a porta para a liberação  
Deve instalar o pacote do FirewallD para poder usar

```bash
sudo apt -y install firewalld
```
```bash
sudo systemctl enable --now firewalld
```
```bash
systemctl status firewalld
```

Liberando a PostgreSQL usando serviço

```bash
sudo firewall-cmd --zone=$(firewall-cmd --get-default-zone) --permanent --add-service=postgresql
```

Liberando a PostgreSQL usando a porta

```bash
sudo firewall-cmd --permanent --add-port=5432/tcp
```

Recarregando as configurações do FirewallD e listando as portas liberadas  

```bash
sudo firewall-cmd --reload
```
```bash
sudo firewall-cmd --list-all
```
___
- Script recomendado: [linux-standby-off](https://github.com/elppans/linux-standby-off)  
___
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
