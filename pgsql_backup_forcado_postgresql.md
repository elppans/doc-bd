# pgsql_backup_forcado_postgresql

você está em **Linux**, com **PostgreSQL**, e o disco já está apresentando **erros de I/O**.
Isso é crítico: quanto mais você acessa o disco, maior a chance de piorar a corrupção.

- Alguns caminhos, do menos intrusivo ao mais "forçado":

---

## 1. Primeiro: verificar se o PostgreSQL ainda está rodando

```bash
sudo systemctl status postgresql
```

Se ainda responde, ótimo: use a própria ferramenta para extrair dados lógicos (dump).

---

## 2. Dump lógico (se o servidor ainda lê os dados)

Forçar um dump simples (sem compressão, sem paralelismo, para reduzir stress de I/O):

```bash
PGUSER=usuario PGPASSWORD=senha pg_dump -h localhost -p 5432 --no-password --format=plain --encoding=LATIN1 --verbose --file=/caminho/backup.sql nome_do_banco
```

- Se der erro de leitura em algumas tabelas, você pode tentar **forçar tabela a tabela**:

```bash
pg_dump -t nome_da_tabela nome_do_banco > tabela.sql
```

Assim você salva pelo menos parte do banco.

---

## 3. Dump binário (se quiser tentar restaurar estrutura mais tarde)

```bash
pg_dump -Fc nome_do_banco > backup.dump
```

Esse formato permite restaurar parcialmente (`pg_restore -t tabela ...`).

---

## 4. Se o banco não sobe mais, mas os arquivos ainda existem

Você pode tentar copiar os **arquivos crus do cluster PostgreSQL** (normalmente em `/var/lib/postgresql/XX/main` ou `/var/lib/pgsql/data`):

```bash
rsync -av --ignore-errors /var/lib/postgresql/ /mnt/hd_externo/postgres_backup/
```

Isso cria uma cópia *mesmo que alguns arquivos falhem*.
Depois, em outra máquina com PostgreSQL da mesma versão, você pode tentar iniciar o cluster ou usar ferramentas de recuperação.

---

## 5. Se nem isso funciona (I/O muito grave)

Use `ddrescue` para salvar o disco ou a partição inteira, tentando pular os setores ruins:

```bash
sudo ddrescue -n /dev/sdX /mnt/hd_externo/image.img /mnt/hd_externo/logfile.log
```

Depois monte essa imagem em outro servidor e tente recuperar os dados do PostgreSQL a partir dela.

---

- **Resumo prático:**

* Se o serviço ainda está rodando: `pg_dump` (mesmo que parcial, tabela por tabela).
* Se não: copiar diretório de dados com `rsync --ignore-errors`.
* Se disco está falhando muito: `ddrescue` primeiro, depois trabalhar na imagem.

---

# Parametro `-n` do ddrescue

No **GNU ddrescue**, o parâmetro **`-n`** significa:

**"Faz apenas a primeira passada rápida, sem tentar reler os setores ruins."**

Ou seja:

* Ele copia todos os blocos legíveis do disco/partição **sem gastar tempo tentando recuperar setores danificados**.
* Isso garante que você salva o **máximo possível de dados bons rapidamente**, reduzindo o tempo de leitura em um disco que pode morrer a qualquer momento.
* Os setores defeituosos ficam registrados no *logfile*, e você pode depois rodar `ddrescue` novamente (sem `-n`, ou usando `-r` para número de tentativas de re-leitura) para tentar recuperar os pedaços que falharam.

---

### Fluxo típico com `ddrescue` em disco problemático:

1. **Primeira passada rápida (sem re-tentativas):**

   ```bash
   ddrescue -n /dev/sdX image.img rescue.log
   ```

2. **Segunda passada, tentando reler os setores ruins algumas vezes:**

   ```bash
   ddrescue -r3 /dev/sdX image.img rescue.log
   ```

   (Aqui `-r3` tenta 3 vezes reler os blocos ruins; pode usar `-r0` = infinito, mas é arriscado e pode matar o disco de vez).

---

- Resumindo:
`-n` serve para **não insistir nos setores ruins na primeira rodada**, copiando rápido o que está saudável. Depois você decide se vale a pena gastar tempo/tentar salvar o resto.

---

