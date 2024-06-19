# PostgreSQL no CentOS 7, FIM DO SUPORTE

[![Fim do suporte CentOS 7 e 8](https://i.imgur.com/Zpk4dzc.png)](https://blog.centos.org/2023/04/end-dates-are-coming-for-centos-stream-8-and-centos-linux-7/)

[Baixe a versão mais recente do CentOS para a instalação](https://www.centos.org/download/#centos-stream)

## Configurando locales:

 Atualmente no CentOS 7, por alguma razão, quando se configura para usar "ISO-8859-1", ao fazer initdb dá esta  mensagem constante:
 
 >WARNING:  could not determine encoding for locale "pt_BR.iso88591": codeset is "ANSI_X3.4-1968"  
LOCATION:  pg_get_encoding_from_locale, chklocale.c:435  

Então, se não estiver configurado ainda, configure para pt_BR.UTF8.  

> Não configure LC_ALL para pt_BR.iso88591  

```
localectl list-locales | grep pt
sudo localectl set-locale LANG=pt_BR.UTF8
localectl status
```

Após a configuração saia e entre na sessão novamente ou reinicie  
Opcionalmente, se não puder reiniciar na hora, exporte a configuração

```
export LANG="pt_BR.UTF8" && export LANGUAGE="pt_BR.UTF8" && export LC_ALL="pt_BR.UTF8"
```

Verifique as variáveis do locales  

```
locale
```

## Configurar repositórios  

Adicionar repositório epel-release e atuanlizar o CentOS 7.  
Deve instalar o pacote utils também.  
Após a atualização, se foi atualizado o Kernel, reinicie o sistema  

```
sudo yum -y install epel-release yum-utils
sudo yum updateinfo
sudo yum -y update
```

Atualize os repositórios  

```
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum-config-manager --disable pgdg* >> /dev/null
sudo yum-config-manager --enable pgdg12 pgdg12-source >> /dev/null
sudo yum -y makecache
sudo yum -y updateinfo
```

# Instalar PostgreSQL 12:  

Instalar PostgreSQL 12  

```
sudo yum install -y postgresql12-server
```

Verificar se a versão foi instalado corretamente  

```
psql --version
```

Verificar se foi criado o usuário postgresql.  
Se não foi, crie e se já foi criado, apenas crie uma senha para ele.  

```
grep postgres /etc/passwd
useradd postgres
```

Criar senha para o usuário postgres  

```
sudo passwd postgres
```

Configurar banco  

```
echo -e 'export PATH="$PATH:/usr/pgsql-12/bin/"\nexport PGDATA="/var/lib/pgsql/12/data/"' | sudo tee -a /etc/bashrc
source /etc/bashrc
su postgres -c "/usr/pgsql-12/bin/initdb -D $PGDATA"
```

Alterar arquivo pg_hba.conf  

```
export IPROUTE=$(ip route show | grep kernel | awk '{ print $1 }' | head -1) && echo $IPROUTE
echo -e "\nhost all all 0.0.0.0/0 trust\n" | sudo tee -a $PGDATA/pg_hba.conf
echo -e "\nhost all all "$IPROUTE" trust\n" | sudo tee -a $PGDATA/pg_hba.conf
```

Alterar arquivo postgresql.conf  

```
sudo sed -i '/listen_addresses/s/#//' $PGDATA/postgresql.conf
sudo sed -i '/listen_addresses/s/localhost/*/' $PGDATA/postgresql.conf
sudo grep listen_addresses $PGDATA/postgresql.conf
sudo sed -i "s/^#*\(port = \).*/\15432/" $PGDATA/postgresql.conf
sudo grep 5432 $PGDATA/postgresql.conf
```

Iniciar o PostgreSQL  

```
sudo systemctl enable --now postgresql-12.service
systemctl status postgresql-12
```

Modificar senha do usuario postgres no template  

>Comando para adicionar em Scripts:

```
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

>Comando para ser executado ao fazer configuração manual:

```
psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

Criar um banco para uso, usando exemplo, com o nome do host.  
Como o PostgreSQL está configurado para usar UTF8, deve ser indicado LATIN1 na criação do banco.  
Vai dar aquela mensagem, mas o banco funciona normal.  

```
createdb -h 127.0.0.1 -p 5432 -U postgres -E LATIN1 --locale=pt_BR.iso88591 -T template0 db.`hostname`

```

Listar bancos  

```
psql -h 127.0.0.1 -p 5432 -U postgres -l
```

Adicionar "Funções" no Banco  

```
curl -JOL https://raw.githubusercontent.com/elppans/zretail/master/function.sql
psql -h 127.0.0.1 -p 5432 -d db.`hostname` -U postgres -W -f function.sql
```

Liberar portas, Firewalld  

Usando FirewallD, pode ser usado o nome do serviço ou diretamente a porta para a liberação  
No CentOS vem instalado por padrão, mas caso não esteja instalado, instale o pacote do FirewallD.  

```
sudo yum -y install firewalld firewalld-filesystem
sudo systemctl enable --now firewalld
systemctl status firewalld
```

Para liberar o PostgreSQL, pode usar tanto o serviço quanto diretamente a porta.  

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

