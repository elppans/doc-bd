# MariaDB, erro "Can't find any matching row in the user table"

## Analisando o Problema e Propondo Soluções

**Entendendo o Erro:**

O erro "Can't find any matching row in the user table" indica que o usuário `mysql` não existe no contexto de conexão remoto (192.168.15.26). Isso significa que o MySQL não reconhece o usuário `mysql` tentando se conectar de outro host.

**Possíveis Causas e Soluções:**

1. **Usuário não existe:**
   * **Verificar existência:** O comando `SELECT User, Host, Password FROM mysql.user;` mostra que o usuário `mysql` existe, mas apenas para conexões locais (localhost).
   * **Criar usuário:** Crie um novo usuário com o mesmo nome, mas especificando o host remoto:
     ```sql
     CREATE USER 'mysql'@'192.168.15.26' IDENTIFIED BY 'sua_senha_forte';
     ```
     Substitua 'sua_senha_forte' pela senha que deseja usar.

2. **Permissões insuficientes:**
   * **Conceder privilégios:** Mesmo que o usuário exista, ele pode não ter privilégios para acessar o banco de dados. Conceda os privilégios necessários:
     ```sql
     GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'mysql'@'192.168.15.26';
     ```
     Substitua 'seu_banco_de_dados' pelo nome do banco de dados ao qual você deseja conceder acesso.

3. **Configuração do MySQL:**
   * **Bind-address:** Verifique se o arquivo de configuração do MySQL (geralmente `/etc/mysql/mysql.conf` ou `/etc/my.cnf`) está configurado para permitir conexões de outros hosts. A linha `bind-address` deve ser definida como `0.0.0.0` para permitir conexões de qualquer IP.
   * **Firewall:** Certifique-se de que o firewall do servidor MySQL está permitindo conexões na porta 3306.

**Solução Completa:**

```sql
# Conecte-se como root
mysql -u root -p

# Crie o usuário mysql para conexões remotas
CREATE USER 'mysql'@'192.168.15.26' IDENTIFIED BY 'sua_senha_forte';

# Conceda privilégios ao usuário
GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'mysql'@'192.168.15.26';
```

**Considerações Adicionais:**

* **Segurança:** Evite usar a mesma senha para todos os usuários.
* **Privilégios:** Conceda apenas os privilégios necessários para cada usuário.
* **Firewall:** Configure o firewall para permitir conexões apenas de IPs confiáveis.
* **Logs:** Ative os logs do MySQL para monitorar as atividades.

**Verificando a Solução:**

Após executar os comandos acima, tente se conectar novamente:

```bash
mysql -u mysql -p -h 192.168.15.26
```

**Outras Possíveis Causas:**

* **Tabela mysql.user corrompida:** Se a tabela `mysql.user` estiver corrompida, você pode precisar restaurá-la a partir de um backup.
* **Configuração do plugin de autenticação:** Se você estiver usando um plugin de autenticação personalizado, verifique se ele está configurado corretamente para permitir conexões remotas.

**Observação:** Se você continuar enfrentando problemas, forneça mais detalhes sobre o seu ambiente, como a versão do MySQL, a distribuição Linux e as mensagens de erro completas.

Com essas informações, você poderá resolver o problema e permitir que o usuário `mysql` se conecte ao banco de dados remotamente.
