# Limpeza de log do PostgreSQL com logrotate

O logrotate é uma ferramenta utilitária essencial em sistemas operacionais Unix/Linux projetada para administrar a criação de grandes volumes de arquivos de log. Ele permite a rotação automática, compressão, remoção e envio por e-mail de arquivos de log, evitando que o disco do servidor fique cheio.
___

Instalação:

- Debian/Ubuntu
sudo apt-get install logrotate

- CentOS/RHEL
sudo yum install logrotate

Editar o arquivo /etc/logrotate.d/postgresql-common (ou /etc/logrotate.d/postgresql, dependendo da Distro) e deixar configurado.
Exemplo do meu Ubuntu 22.04:

```
/var/log/postgresql/*.log {
    size 100M
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    create 0640 postgres adm
    su root root
    postrotate
        /usr/bin/systemctl reload postgresql > /dev/null 2>&1 || true
    endscript
}
```

Explicação das diretivas (Somente as principais):

- daily → Roda a rotação todos os dias.
- rotate 7 → Mantém 7 arquivos antigos antes de apagar.
- compress → Compacta os logs antigos para economizar espaço.
- copytruncate → Evita problemas ao truncar o arquivo atual sem mudar permissões.
- create → Cria novo arquivo com permissões corretas (0640 postgres:postgres).
- postrotate → Recarrega o PostgreSQL após a rotação, garantindo que ele continue escrevendo no novo log.

O logrotate roda automaticamente todo dia — mas não é ele sozinho que decide isso. No Ubuntu (e na maioria das distribuições Linux), o logrotate é chamado pelo cron ou pelo systemd timer:

```
ls /etc/cron.daily/
systemctl status logrotate.timer
```
___
## Comandos Úteis

- Forçar a rotação imediatamente:
```
sudo logrotate -f /etc/logrotate.provider_config
```

- Modo de teste (Dry Run):
Mostra o que o logrotate faria, mas sem alterar nenhum arquivo real. Excelente para validar sintaxe.
```
sudo logrotate -d /etc/logrotate.d/nginx
```
>O estado de quando cada log foi rotacionado pela última vez fica salvo no arquivo /var/lib/logrotate/status.
