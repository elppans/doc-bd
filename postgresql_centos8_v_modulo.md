# PostgreSQL no CentOS 8, via módulo

## Configurar repositórios *(OPCIONAL)*  

Para a instalação do PostgreSQL, não é necessário adicionar o repositório *epel*, pois será usado `@appstream`.  
Independente de adicionar ou não, atualize a Distro.  
Após a atualização, se foi atualizado o Kernel, reinicie o sistema.  

```
sudo dnf -y install epel-release
sudo dnf updateinfo
sudo dnf -y update
```

### Garantir que não tenha conflitos na instalação

```
sudo dnf -y config-manager --disable pgdg* &>> /dev/null
dnf -y makecache
dnf -y updateinfo
```

### Desativar módulos PostgreSQL embutido:

```
sudo dnf -qy module disable postgresql
```

### Ativar móudlo PostgreSQL embutido `versão especifica`:

```
sudo dnf module -qy enable postgresql:12
sudo dnf module list --enabled postgresql
```

# Instalar PostgreSQL:

```
sudo dnf install -y postgresql-server
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
Diferente da versão do CentOS 7, até o momento em que escrevo a matéria, não há problemas ao iniciar o banco usando ISO-8859-1 (LATIN1).  
Então, inicie o banco com esta configuração. Se der mensagens de aviso anormais, apague o conteúdo da pasta data e configure novamente, com a linguagem e codificação padrão do sistema.  

```
export PGDATA="/var/lib/pgsql/data"
su postgres -c "initdb --locale=pt_BR.iso88591 --lc-collate=pt_BR.iso88591 --lc-ctype=pt_BR.iso88591 --encoding=LATIN1 -D $PGDATA"
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
sudo systemctl enable --now postgresql.service
systemctl status postgresql
```

Modificar senha do usuario postgres no template  

```
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
```

Criar um banco para uso, usando exemplo, com o nome do host.  
*SE* o PostgreSQL está configurado para usar UTF8, deve ser indicado `LATIN1` na criação do banco.  
Vai dar aquela mensagem, mas o banco funciona normal.  
Se o banco foi criado com a codficação padrão LATIN1, basta criar o banco sem especificar nada.  

```
createdb -h 127.0.0.1 -p 5432 -U postgres db.`hostname`

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

