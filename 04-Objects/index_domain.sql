-- List Preferences 
SELECT * FROM ctx_preferences WHERE pre_owner = 'ERP';
SELECT * FROM ctx_preference_values WHERE prv_owner = 'ERP';

-- List Stoplists
SELECT * FROM ctx_stoplists WHERE spl_owner = 'ERP';
SELECT * FROM ctx_stopwords WHERE spw_owner = 'ERP';

-- Index Domain: list
SELECT i.owner,
       index_name,
       ityp_owner,
       ityp_name,
       parameters,
       i.status,
       domidx_status,
       domidx_opstatus,
       o.created
  FROM dba_indexes i INNER JOIN 
  dba_objects o ON i.owner = o.owner
  AND i.index_name = o.object_name
 WHERE i.owner = 'ERP' AND index_type = 'DOMAIN'
-- AND TRUNC(created) = TRUNC(SYSDATE)
ORDER BY created DESC;

-- Index Domain: rebuild
SELECT 'alter index "' || owner || '"."' || index_name || (CASE
         WHEN upper(PARAMETERS) LIKE '%REPLACE%' THEN
          '" rebuild parameters (''' || lower(replace(PARAMETERS, ' thema', ' erp.thema')) || '''' || ');'
         ELSE
          '" rebuild parameters (''replace ' || lower(replace(PARAMETERS, ' thema', ' erp.thema')) || '''' || ');'
       END) rebuild_indexes
  FROM dba_indexes i
 WHERE i.index_type = 'DOMAIN'
   AND i.table_owner = 'ERP';

-- Index Domain: invalid
SELECT owner,
       index_name,
       ityp_owner,
       ityp_name,
       parameters,
       status,
       domidx_status,
       domidx_opstatus
  FROM dba_indexes
 WHERE index_type = 'DOMAIN'
 AND (status <> 'VALID'
 OR domidx_status <> 'VALID'
 OR domidx_opstatus <> 'VALID');

-------------------------------------------------------------------------------------------------------------------------------------------------

-- DRG-10507 – Duplicate Index Name
DROP INDEX ERP.GRP_JZX_CONTEUDO_CTX; --> erro ao executar o drop normal

-- Executar: 
DROP INDEX ERP.&INDEX_NAME FORCE;
DROP TABLE ERP.DR$&INDEX_NAME$I;
DROP TABLE ERP.DR$&INDEX_NAME$K;
DROP TABLE ERP.DR$&INDEX_NAME$N;
DROP TABLE ERP.DR$&INDEX_NAME$U;

-- Identificar INDEX_ID: (https://dincosman.com/2023/06/17/context-index-orphans/)
SELECT pnd_cid, MIN (pnd_timestamp), COUNT (*) FROM ctxsys.dr$pending GROUP BY pnd_cid ORDER BY MIN (pnd_timestamp) DESC;

-- Deletar registros relacionados
DELETE FROM ctxsys.dr$index_value where IXV_IDX_ID=1453;
DELETE FROM ctxsys.dr$index_object  where IXO_IDX_ID=1453;
DELETE FROM ctxsys.dr$pending  where pnd_cid=1453;
DELETE FROM ctxsys.dr$index  where idx_id=1453;   

-------------------------------------------------------------------------------------------------------------------------------------------------