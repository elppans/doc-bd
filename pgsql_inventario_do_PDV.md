# Consulta Inventário PDV, SAT

-- Varredura PDV
-- Varredura informações tab_pdv
-- COM informações de SAT
-- Consulta, verificar CONDFONS, moduloPHPPDV, Sistema, etc
-- TAGS: Versão PDV, Versão moduloPHPPDV, CODFON, Sistema
-- Consulta, verificar CONDFONS, moduloPHPPDV, Sistema, etc
```
WITH ParsedXML AS (
    SELECT 
        tp.cod_loja,
        tp.cod_pdv,
        COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/VERSAO/text()', tp.inventario::xml), ''), '') AS versao,
        COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/DISTRO_SO/text()', tp.inventario::xml), ''), '') AS distro_so,
        COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/MODULOPHP/text()', tp.inventario::xml), ''), '') AS modulophp,
        COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/VERSAO_CLISITEF/text()', tp.inventario::xml), ''), '') AS versao_clisitef,
        tp.modelo_ecf,
        tp.marca_ecf,
        tp.inventario
    FROM tab_pdv tp
)

SELECT 
    px.*,
    ts.cod_loja,
    tl.des_fantasia,
    ts.num_pdv,
    ts.serie,
    (CURRENT_DATE - ts.dth_ult_comunicacao_ctsat::date) AS dias_sem_comunicar,
    (CURRENT_DATE - ts.cert_vencimento::date) AS dias_vencidos,
    ts.modelo_sat,
    ts.lan_ip,
    ts.status_lan,
    ts.ver_layout,
    ts.ver_sb,
    ts.ultimo_cfe_transmitido,
    ts.dth_atual,
    ts.cert_vencimento,
    SUBSTRING(ts.lista_inicial, 32, 6) AS numero_nota_inicial,
    SUBSTRING(ts.lista_final, 32, 6) AS numero_nota_final,
    quantidade_envio_sefaz,

    CASE WHEN ts.ver_layout::text = '0.07' THEN 1 ELSE 0 END AS status_atualizacao,
    CASE WHEN ts.versao_ctsat != 'CTSAT v2.1.0' THEN 1 ELSE 0 END AS status_versao_ctsat

FROM tab_sat ts
LEFT JOIN tab_loja tl ON ts.cod_loja = tl.cod_loja 
LEFT JOIN ParsedXML px ON px.cod_pdv = ts.num_pdv AND px.cod_loja = ts.cod_loja

CROSS JOIN LATERAL (
    SELECT 
        CAST(SUBSTRING(ts.lista_final, 32, 6) AS INTEGER) - CAST(SUBSTRING(ts.lista_inicial, 32, 6) AS INTEGER) 
        AS quantidade_envio_sefaz
) AS qte

WHERE
    px.cod_loja IS NOT NULL 
    AND (
        (CURRENT_DATE - ts.cert_vencimento::date) >= -30
        OR (CURRENT_DATE - ts.dth_ult_comunicacao_ctsat::date) >= 7
        OR ts.dth_ult_comunicacao_ctsat IS NULL
        OR quantidade_envio_sefaz >= 20
        OR ts.ver_layout::text = '0.07'
        OR ts.versao_ctsat != 'CTSAT v2.1.0'
    )

ORDER BY 
    ts.cod_loja,
    ts.num_pdv;
```
-----------------------------------------------------------------------------------------------------------------

# Consulta Inventário PDV, SEM SAT

-- Varredura PDV
-- Varredura informações tab_pdv
-- Sem informações de SAT
-- Consulta, verificar CONDFONS, moduloPHPPDV, Sistema, etc
-- TAGS: Versão PDV, Versão moduloPHPPDV, CODFON, Sistema
-- Daniel quem me passou e eu fucei xD
```
SELECT
	tp.cod_loja,
	tp.cod_pdv,
	tp.ip_pdv,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/VERSAO/text()', tp.inventario::xml), ''), '') AS versao,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/DISTRO_SO/text()', tp.inventario::xml), ''), '') AS distro_so,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/MODULOPHP/text()', tp.inventario::xml), ''), '') AS modulophp,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/VERSAO_CLISITEF/text()', tp.inventario::xml), ''), '') AS versao_clisitef,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/EXEC/text()', tp.inventario::xml), ''), '') AS EXEC_ECF,
	COALESCE(array_to_string(xpath('/ZEUS_INFOPDV/DATAMOVIMENTO/text()', tp.inventario::xml), ''), '') AS DATA_MOVIMENTO,
	tp.modelo_ecf,
	tp.marca_ecf,
	tp.porta_pdv, 
	tp.num_fabricacao,
	tp.inventario
FROM tab_pdv tp
ORDER BY 
    tp.cod_loja,
    tp.cod_pdv;
```
_______________________________

# Ubuntu 22, Correção de informação no XML, "DISTRO_SO"

-- Trocar Release S.O. por Release Zanthus
```
VERPDV="\"Zeus PDV $(cat /etc/canoalinux-release )\"" && sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=$VERPDV/g" /etc/lsb-release
```
-- Fixar configuração para que não seja modificado em atualização posterior do sistema (OPCIONAL)
```
dpkg-divert --add --rename --divert /etc/lsb-release.real /etc/lsb-release
cp -a /etc/lsb-release.real /etc/lsb-release
```
