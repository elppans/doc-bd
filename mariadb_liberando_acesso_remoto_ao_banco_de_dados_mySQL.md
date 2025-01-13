# MariaDB, Liberando Acesso Remoto ao Banco de Dados MySQL

### Entendendo o Problema
Você deseja permitir que seu computador se conecte ao banco de dados MySQL que está rodando em outro dispositivo com o IP 192.168.15.26. Atualmente, o usuário `mysql` possui privilégios excessivos e o acesso está limitado ao localhost.

### Solução Passo a Passo

**1. Conecte-se ao MySQL como root:**
   ```bash
   mysql -u root -p
   ```
   Substitua `-p` pela sua senha de root.

**2. Crie um novo usuário com permissões específicas:**
   ```sql
   CREATE USER 'seu_usuario'@'192.168.15.26' IDENTIFIED BY 'sua_senha';
   GRANT ALL PRIVILEGES ON seu_banco_de_dados.* TO 'seu_usuario'@'192.168.15.26';
   ```
   * **`seu_usuario`:** Substitua por um nome de usuário de sua escolha.
   * **`192.168.15.26`:** Substitua pelo IP do computador onde o MySQL está rodando.
   * **`sua_senha`:** Defina uma senha forte.
   * **`seu_banco_de_dados`:** Substitua pelo nome do banco de dados ao qual você deseja conceder acesso.

**3. Verifique as configurações do MySQL:**
   * **Arquivo de configuração:** Abra o arquivo de configuração do MySQL (geralmente `/etc/mysql/mysql.conf` ou `/etc/my.cnf`) e procure pela linha `bind-address`.
   * **Altere para 0.0.0.0:** Se o valor estiver definido como `127.0.0.1`, altere para `0.0.0.0` para permitir conexões de qualquer IP.
   * **Reinicie o serviço MySQL:** Após fazer a alteração, reinicie o serviço MySQL para que as novas configurações entrem em vigor. Em sistemas Ubuntu/Debian, você pode usar o comando:
     ```bash
     sudo systemctl restart mysql
     ```

**4. Conecte-se usando o novo usuário:**
   ```bash
   mysql -u seu_usuario -p -h 192.168.15.26
   ```
   Substitua `seu_usuario` e `192.168.15.26` pelos valores que você configurou.

### Considerações Importantes:

* **Segurança:**
  * **Senhas fortes:** Utilize senhas complexas e únicas para cada usuário.
  * **Permissões mínimas:** Conceda apenas os privilégios necessários para cada usuário.
  * **Firewall:** Configure seu firewall para permitir conexões na porta 3306 (porta padrão do MySQL) somente para IPs confiáveis.
* **Limitação de hosts:** Se você quiser limitar o acesso a um conjunto específico de IPs, liste-os separadamente no comando `GRANT`.
* **Usuário root:** Evite usar o usuário `root` para conexões remotas.
* **Logs:** Ative os logs do MySQL para monitorar as atividades.

### Exemplo Completo:

```sql
# Conecte-se como root
mysql -u root -p

# Crie um novo usuário com acesso remoto
CREATE USER 'meu_usuario'@'192.168.15.26' IDENTIFIED BY 'senha123';
GRANT ALL PRIVILEGES ON meu_banco_de_dados.* TO 'meu_usuario'@'192.168.15.26';

# Verifique as configurações do MySQL (arquivo my.cnf)
# Altere bind-address para 0.0.0.0 e reinicie o serviço

# Conecte-se usando o novo usuário
mysql -u meu_usuario -p -h 192.168.15.26
```

**Observações:**

* **Configuração do Firewall:** Certifique-se de que o firewall do servidor MySQL e do seu computador estejam configurados para permitir as conexões na porta 3306.
* **Segurança:** A configuração `bind-address = 0.0.0.0` permite conexões de qualquer IP. Se você quiser limitar o acesso a um conjunto específico de IPs, configure o firewall de forma mais restritiva.
* **Privilégios:** Ajuste os privilégios concedidos ao usuário de acordo com suas necessidades.

Ao seguir esses passos, você poderá conectar ao seu banco de dados MySQL remotamente de forma segura.
