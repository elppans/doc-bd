# PostgreSQL no CentOS, via repositório PGDG

- Antes de continuar veja informações sobre o CentOS 7 e 8 Stream, clique na imagem abaixo para mais informações.

[![Fim do suporte CentOS 7 e 8](https://i.imgur.com/Zpk4dzc.png)](https://blog.centos.org/2023/04/end-dates-are-coming-for-centos-stream-8-and-centos-linux-7/)

[**Baixe a versão mais recente do CentOS para a instalação**](https://www.centos.org/download/#centos-stream)
>Até o momento da publicação desta matéria o mais recente é o **CentOS 9 Stream**

## Configuração dos repositórios 

Para a instalação do PostgreSQL, não é necessário adicionar o repositório **epel**.  
Independente de adicionar ou não, **atualize a Distro**.  
Após a atualização, **se foi atualizado o Kernel, reinicie o sistema**.  

```bash
sudo dnf updateinfo
```
```bash
sudo dnf -y update
```

## PostgreSQL via repositório RPM:

Para mais informações acesse o **site oficial**, [PostgreSQL, Download, família Red Hat](https://www.postgresql.org/download/linux/redhat/)

### Instalar repositório PGDG

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

### Desative os repositórios PGDG das versões que não serão usadas
>Será instalado a versão 16, que é a versão estável mais alta, no momento da publicação desta matéria.  
>Para instalar outra versão, acesse o site oficial [postgresql.org](https://www.postgresql.org/).  

```bash
sudo dnf -y config-manager --disable pgdg{12,13,14,15} &>> /dev/null
```

### Desativar módulos PostgreSQL embutido:

```bash
sudo dnf -qy module disable postgresql
```

### Validar a llista de módulos, se está desativado

```bash
sudo dnf module list --disabled
```

### Atualizar a lista de repositórios

```bash
sudo dnf -y updateinfo
```

# Instalar PostgreSQL:

```bash
sudo dnf install -y postgresql16-server
```

Verificar se a versão desejada foi instalado corretamente  

```bash
psql --version
```

### Inicialize o banco de dados e habilite o início automático:

- Iniciar uso do banco de dados

```bash
sudo /usr/pgsql-16/bin/postgresql-16-setup initdb
```

- Ativar o PostgreSQL na inicialização do sistema (SystemD)

```bash
sudo systemctl enable postgresql-16
```

- Iniciar o serviço do PostgreSQL

```bash
sudo systemctl start postgresql-16
```

- Verificar o estado do serviço:

```bash
sudo systemctl status postgresql-16
```

### Alterar arquivo pg_hba.conf  

- Host PGSQL:
  
Edite o arquivo `/var/lib/pgsql/{VERSAO}/data/pg_hba.conf` e adicione no final do arquivo o IP `0.0.0.0` e o IP do servidor para que seja liberado a comunicação do Manager com o banco:



```ini
host all all 0.0.0.0/0 trust
host all all 192.168.15.90/24 trust
```

- Autenticação PGSQL:

1. **Autenticação Peer** (Padrão):
   - Usado para autenticar conexões locais no PostgreSQL.
   - No entanto, pode causar problemas, como o erro "FATAL: A autenticação do tipo peer falhou".
   - Para resolver, modifique o arquivo para usar outro método de autenticação, como "md5".

2. **Autenticação MD5**:
   - Ele gera um hash de 128 bits para dados, um algoritmo de resumo de mensagem usado para autenticar mensagens e verificar conteúdo.
   - Para usar, modifique a 1º linha **"local"** trocando o usuário **`all`** para **`postgres`** e adicione no final do arquivo `pg_hba.conf` uma linha como esta*:
>a 1º linha **"local"**, pode comentar a linha e no final do arquivo adicionar a linha do postgres, se não quiser ficar usando senha até na linha de comando, troque md5 para trust
   
     ```ini
     local   all     postgres md5
     ...
     local   all     pgadmin md5
     ```
     
   - Isso permite que o software gere e verifique o resumo MD5 de cada segmento enviado na conexão TCP.
   - *Crie um usuário no PostgreSQL para usar este método e para fazer tarefas administrativas:

      ```bash
      sudo -u postgres createuser -d -l -P -r -s --replication pgadmin
      ```

### Alterar arquivo postgresql.conf  

Ache a linha com listen_addresses, descomente e deixe desta forma:

```ini
listen_addresses = '*'  
```

Ache a linha que tem `port = 5432` e se estiver comentado, descomente.
Depois salve e saia do editor.

```ini
port = 5432
```

Reiniciar o PostgreSQL  

```bash
sudo systemctl restart postgresql-16
```

- **Para a configuração de pós instalação do PostgreSQL, veja:**
[**Comandos pgsql via Terminal**](https://elppans.github.io/doc-bd/pgsql_via_Terminal)

### Liberar portas, SELINUX  
>Ajustar SELinux (se estiver em modo enforcing - De qualquer forma, independente é recomendado fazer esta configuração)

Se o PostgreSQL estiver escutando em uma porta diferente da padrão, você precisa registrar essa porta.
>Pelos meus testes, mesmo usando a porta padrão 5432, é recomendado fazer esta configuração

- Porta fora do padrão
```bash
sudo semanage port -a -t postgresql_port_t -p tcp 5433
```
- Porta padrão
```bash
sudo semanage port -a -t postgresql_port_t -p tcp 5432
```
### Liberar portas, Firewalld  

Usando FirewallD, pode ser usado o nome do serviço ou diretamente a porta para a liberação  
No CentOS vem instalado por padrão, mas caso não esteja instalado, instale o pacote do FirewallD.  
> Se não for a intenção usar o FirewallD, Ignore esta sessão da matéria e finalizar por aqui.  

```
sudo yum -y install firewalld firewalld-filesystem
```
```bash
sudo systemctl enable --now firewalld
```
```bash
systemctl status firewalld
```

Para liberar o PostgreSQL, pode usar tanto o serviço quanto diretamente a porta.  

- Liberando a PostgreSQL usando serviço:  

```bash
sudo firewall-cmd --zone=$(firewall-cmd --get-default-zone) --permanent --add-service=postgresql
```

- Liberando a PostgreSQL usando a porta:  

```bash
sudo firewall-cmd --permanent --add-port=5432/tcp
```

- Recarregar as configurações do FirewallD:    

```bash
sudo firewall-cmd --reload 
```

- Listando as portas liberadas:

```bash
sudo firewall-cmd --list-all
```
