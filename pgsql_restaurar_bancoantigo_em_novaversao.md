# Restaurar um banco versão antiga em uma nova versão

<img width="808" height="282" alt="image" src="https://github.com/user-attachments/assets/e8d61056-92b7-4c15-bfb8-b72b871d84f2" />
___


Esse arquivo (`.backup`) é um **dump lógico em formato custom** (`pg_dump -Fc`), feito no **PostgreSQL 10**.

👉 **Boa notícia**:
Dumps **lógicos** (`pg_dump` e `pg_restore`) **são compatíveis entre versões maiores**.
Ou seja, você pode restaurar esse `.backup` direto no PostgreSQL 16 — o `pg_restore` do 16 entende o formato gerado pelo 10.

---

### Como restaurar

1. Criar um banco novo vazio (não restaure em cima de um existente):

   ```bash
   createdb -U postgres novo_banco
   ```

2. Rodar o `pg_restore`:

   ```bash
   pg_restore -U postgres -d novo_banco /opt/backup/db.buri.srv-2.14.135.0_20052022.090636.backup
   ```

---

### Dicas:

* Se quiser ver **o que tem dentro do backup** antes de restaurar:

  ```bash
  pg_restore -l db.buri.srv-2.14.135.0_20052022.090636.backup | less
  ```

  (mostra lista de objetos, tabelas, funções, etc).

* Se precisar restaurar **só algumas tabelas**:

  ```bash
  pg_restore -U postgres -d novo_banco -t nome_da_tabela arquivo.backup
  ```

* Se quiser forçar sobrescrever (cuidado ⚠️):

  ```bash
  pg_restore -U postgres -d novo_banco --clean --create arquivo.backup
  ```

---

📌 Resumindo: esse backup vai te servir sim, porque está no formato lógico (portável entre versões). O que **não funcionaria** seria copiar o diretório físico de um PostgreSQL 10 e tentar abrir no 16 — isso só funciona dentro da mesma versão ou com `pg_upgrade`.

---


# Descobrindo qual o formato foi usado para criar o backup

Na imagem, foi feito o comando:  

```bash
file db.buri.srv-2.14.135.0_20052022.090636.backup
```

E a saída foi:  

```
PostgreSQL custom database dump - v1.13-0
```

Esse texto **vem do utilitário `file`** que reconhece o cabeçalho binário do arquivo.
O `pg_dump` tem três formatos principais:

* **plain** (texto SQL) → arquivo legível com `cat`, cheio de `CREATE TABLE`, `INSERT`, etc.
* **custom (`-Fc`)** → binário, mostrado exatamente como o seu caso (`custom database dump`).
* **directory (`-Fd`)** → gera uma pasta com vários arquivos.

Como o que está na imagem, está identificado como **"PostgreSQL custom database dump"**, isso significa que ele foi gerado com `pg_dump -Fc`.

---

Quer que eu te mostre como verificar rapidamente **qual versão do pg\_dump** foi usada pra gerar esse `.backup`? (dá pra extrair do cabeçalho com `pg_restore -l`).

___

# Utilizando a melhor maneira de restaurar

- Cenário:
O arquivo está em "/mnt/opt/BDBKP/db.buri.srv-2.14.135.0_20052022.090636.backup";
O nome do banco novo é "db.burisrv";
Estou logado com o usuário postgres (Fiz sudo su - postgres).
___

Como o arquivo é **formato custom** (`.backup`) e você quer restaurar no banco novo `db.burisrv`, use o `pg_restore` do PostgreSQL 16.

### Caminho simples (recomendado)

Cria o banco vazio e restaura tudo nele:

```bash
# já está como usuário postgres
createdb db.burisrv

pg_restore \
  -d db.burisrv \
  -j 4 \
  --no-owner \
  --role=postgres \
  /mnt/opt/BDBKP/db.buri.srv-2.14.135.0_20052022.090636.backup
```

**Notas rápidas**

* `-j 4`: paralelismo (ajuste ao nº de CPUs).
* `--no-owner --role=postgres`: aplica objetos como `postgres` (evita erro se os donos/roles do backup não existem mais).
* Se aparecer erro de extensão faltando, crie antes, p.ex.: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";` no `db.burisrv`, e rode o `pg_restore` de novo.

### Se quiser conferir o conteúdo antes

```bash
pg_restore -l /mnt/opt/BDBKP/db.buri.srv-2.14.135.0_20052022.090636.backup | less
```

### Alternativa: restaurar em duas fases

Útil se você quer ver schema separado de dados.

```bash
# schema
pg_restore -d db.burisrv -s \
  --no-owner --role=postgres \
  /mnt/opt/BDBKP/db.buri.srv-2.14.135.0_20052022.090636.backup

# dados
pg_restore -d db.burisrv -a -j 4 \
  --no-owner --role=postgres \
  /mnt/opt/BDBKP/db.buri.srv-2.14.135.0_20052022.090636.backup
```

Isso é o necessário pra colocar o backup de 2020 (PG10) rodando no PG16.

