A estratégia de **`ALTER TABLE … DISABLE TRIGGER ALL`** funciona porque o PostgreSQL não valida as FKs no momento da importação e aceita todas as linhas.

Um lembrete importante:

* Quando você roda `DISABLE TRIGGER ALL`, o banco também deixa de validar **foreign keys** e **checks** daquela tabela;
* Quando volta com `ENABLE TRIGGER ALL`, ele **não faz uma checagem retroativa** — ou seja, se entrou dado “órfão”, vai ficar lá pra sempre, a menos que você corrija manualmente.

👉 Se a ideia é só **popular rápido** (tipo migração/dump), esse esquema está perfeito.
👉 Se for base de produção, recomendo depois rodar queries de consistência, tipo:

```sql
SELECT *
FROM tab_cliente c
WHERE NOT EXISTS (
    SELECT 1 FROM municipio m WHERE m.id = c.municipio_id
);
```

Assim você detecta linhas que ficaram sem referência.

