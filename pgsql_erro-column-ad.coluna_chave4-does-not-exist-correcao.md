# Erro: column ad.coluna_chave4 does not exist: Correção

- **Cortando o nome:**

ad. = Adicionar tabela ou coluna
coluna_ = Significa que o código mencionado é uma coluna
chave4 ou "coluna_chave4" = É o nome da coluna a ser adiconada

- **Procurando a coluna:**

**Se não souber o nome completo da coluna**:
Se você não sabe o nome completo da coluna, pode usar o operador LIKE ou ILIKE

- **LIKE ou ILIKE:**

LIKE '%chave%': Retorna todas as colunas que contêm a palavra "chave" no nome.
O operador % é um curinga que representa qualquer sequência de caracteres antes ou depois de "chave".
Se quiser evitar distinção entre maiúsculas e minúsculas, use ILIKE em vez de LIKE.

- **Usando o Select:**

```
select 
    table_name AS Nome_Tabela,
    column_name AS Nome_Coluna, 
    data_type AS Tipo_Dado,
    character_maximum_length as Tamanho
from information_schema.columns
--where table_name = 'tab_loja' -- Ver as colunas da tabela
--where column_name = 'cod_loja' -- Procura qual tabela tem a coluna específica
where column_name LIKE '%chave4%' -- Busca colunas cujo nome contém 'chave4'
order by column_name;
```

- **Alterando ou corrigindo a(s) coluna(s) encontradas:**

```
alter table tab_agendamento_detalhe add column coluna_chave4  varchar(30);
```
```
alter table tab_agendamento_detalhe add column valor_chave4  varchar(50);
```
