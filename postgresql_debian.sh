#!/bin/bash

# Verificar se o arquivo locale.alias existe
if [ -f /etc/locale.alias ]; then
    # Verificar se a entrada 'pt_BR pt_BR.ISO-8859-1' já está configurada em locale.alias
    if grep -q "pt_BR pt_BR.ISO-8859-1" /etc/locale.alias; then
        echo "A entrada 'pt_BR pt_BR.ISO-8859-1' já está configurada em locale.alias."
    else
        echo "Adicionando a entrada 'pt_BR pt_BR.ISO-8859-1' em locale.alias..."
        echo "pt_BR pt_BR.ISO-8859-1" | sudo tee -a /etc/locale.alias
        sudo locale-gen
        echo "A entrada 'pt_BR pt_BR.ISO-8859-1' foi adicionada e os locales foram regenerados."
    fi
else
    echo "O arquivo locale.alias não foi encontrado em /etc/locale.alias."
fi

# Verificar se o locale pt_BR ISO-8859-1 está ativado e descomentado em locale.gen
if grep -q "pt_BR ISO-8859-1" /etc/locale.gen; then
    if grep -q "# pt_BR ISO-8859-1" /etc/locale.gen; then
        echo "Descomentando e ativando o locale 'pt_BR ISO-8859-1' em locale.gen..."
        sudo sed -i "s/# pt_BR ISO-8859-1/pt_BR ISO-8859-1/" /etc/locale.gen
        sudo locale-gen
        echo "O locale 'pt_BR ISO-8859-1' foi ativado e descomentado, e os locales foram regenerados."
    else
        echo "O locale 'pt_BR ISO-8859-1' já está ativado e não está comentado em locale.gen."
    fi
else
    echo "Ativando o locale 'pt_BR ISO-8859-1' em locale.gen..."
    echo "pt_BR ISO-8859-1" | sudo tee -a /etc/locale.gen
    sudo locale-gen
    echo "O locale 'pt_BR ISO-8859-1' foi ativado e os locales foram regenerados."
fi

# Instalar certificados e repositório PostgreSQL
sudo apt -y install curl ca-certificates gnupg

# Criar a configuração do repositório de arquivos
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Importar a chave de assinatura do repositório
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

#!/bin/bash

# Variáveis de configuração
export PGDATA="/var/lib/postgresql/12/main"
export PGHBA_CONF="/etc/postgresql/12/main/pg_hba.conf"
export POSTGRES_CONF="/etc/postgresql/12/main/postgresql.conf"
export PORT="5432"

# Função para verificar e ativar a porta 5432
check_and_activate_port() {
    if grep -q "^port = $PORT" "$POSTGRES_CONF"; then
        echo "A porta $PORT já está configurada em postgresql.conf."
    else
        echo "Ativando a porta $PORT em postgresql.conf..."
        sudo sed -i "s/^#*\(port = \).*/\15432/" "$POSTGRES_CONF"
        echo "Porta $PORT ativada em postgresql.conf."
    fi
}

# Fazer backup dos arquivos de configuração
timestamp=$(date +"%Y%m%d%H%M%S")
sudo cp "$PGHBA_CONF" "$PGHBA_CONF.$timestamp.bak"
sudo cp "$POSTGRES_CONF" "$POSTGRES_CONF.$timestamp.bak"

# Instalar o PostgreSQL 12
sudo apt update
sudo apt install postgresql-12 -y

# Configurar o cluster do PostgreSQL
sudo pg_ctlcluster 12 main stop
sudo pg_dropcluster 12 main
sudo pg_createcluster --locale=pt_BR.iso88591 -e LATIN1 12 main
sudo pg_ctlcluster 12 main start

# Fazer backup dos arquivos de configuração
sudo cp "$PGHBA_CONF" "$PGHBA_CONF.$timestamp.after_cluster.bak"
sudo cp "$POSTGRES_CONF" "$POSTGRES_CONF.$timestamp.after_cluster.bak"

# Verificar e ativar a porta 5432
check_and_activate_port

# Configurar o PostgreSQL para ouvir em todas as interfaces
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$POSTGRES_CONF"

# Permitir autenticação via senha para conexões locais
#echo "host    all             all             127.0.0.1/32            md5" | sudo tee -a "$PGHBA_CONF"

Adicionar IP local ao arquivo pg_hba.conf

# Detectar o IP da interface padrão
export IPROUTE=$(ip route show | grep default | awk '{print $3}')

# Calcular a rede correspondente
IFS=. read -r i1 i2 i3 i4 <<< "$IPROUTE"
NETWORK="$i1.$i2.$i3.0/24"

LOCAL_IP_RULE="host all all 0.0.0.0/0 trust"
NETWORK_IP_RULE="host all all $NETWORK trust"

echo -e "\n$LOCAL_IP_RULE" | sudo tee -a "$PGHBA_CONF"
echo -e "\n$NETWORK_IP_RULE" | sudo tee -a "$PGHBA_CONF"

# Reiniciar o PostgreSQL para aplicar as configurações
sudo systemctl restart postgresql
systemctl status postgresql

# Adicionar senha no usuário postgres no sistema
#echo -e 'postgres\npostgres' | sudo passwd postgres

# Modificar senha do usuario postgres no template
#psql -U postgres -h 127.0.0.1 -p 5432 -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres'" -d template1

# Criar outro usuário para poder fazer tarefas pgadministrativas
sudo -u postgres createuser -d -l -P -r -s --replication pgadmin

# Listar usuários no banco
sudo -u postgres psql -c "\du"

# Criar um banco host
#createdb -h 127.0.0.1 -p 5432 -U pgadmin db.`hostname` db.`$hostname`
#createdb -h 127.0.0.1 -p 5432 -U postgres db.`$hostname`2 db.`$hostname`2
#sudo -u postgres createdb -h 127.0.0.1 db.`$hostname`3 db.`$hostname`3
sudo -u postgres createdb -w db.`$hostname` db.`$hostname`

# Criar um banco com o nome ZeusRetail
#createdb -h 127.0.0.1 -p 5432 -U pgadmin ZeusRetail ZeusRetail
sudo -u postgres createdb -w ZeusRetail ZeusRetail

# Adicionar "Funções" Zanthus no Banco
wget -c https://raw.githubusercontent.com/elppans/zretail/master/function.sql -P /tmp
psql -h 127.0.0.1 -p 5432 -d ZeusRetail -U pgadmin -W -f /tmp/function.sql

# Listar bancos
psql -h 127.0.0.1 -p 5432 -U pgadmin -l

# Trancar senha no usuário postgres no sistema
sudo passwd -l postgres >> /dev/null

echo "Instalação e configuração concluídas!"
