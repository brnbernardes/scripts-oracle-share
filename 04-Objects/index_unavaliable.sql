-- Index
SELECT owner,
       index_name,
       'alter index ' || owner || '.' || index_name || ' rebuild;' cmdfrom
  FROM dba_indexes
 WHERE status = 'UNUSABLE';

-- Rebuild
SELECT 'alter index ' || owner || '.' || index_name || ' rebuild ' ||
       ' tablespace ' || tablespace_name || ';' cmd
  FROM dba_indexes
 WHERE status = 'UNUSABLE'
UNION
SELECT 'alter index ' || index_owner || '.' || index_name ||
       ' rebuild partition ' || partition_name || ' tablespace ' ||
       tablespace_name || ';'
  FROM dba_ind_partitions
 WHERE status = 'UNUSABLE'
UNION
SELECT 'alter index ' || index_owner || '.' || index_name ||
       ' rebuild subpartition ' || subpartition_name || ' tablespace ' ||
       tablespace_name || ';'
  FROM dba_ind_subpartitions
 WHERE status = 'UNUSABLE';

-- Domain (context)
SELECT owner,
       index_name,
       ityp_owner,
       ityp_name,
       parameters,
       status,
       domidx_status,
       domidx_opstatus
  FROM dba_indexes
 WHERE index_type = 'DOMAIN';

-- Rebuild
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

-- Verificar index domain compilados sem parâmetro 
select 'alter index '||index_name||' rebuild'|| 
       (select case regexp_count(banner,'Enterprise|EE') when 0 then ' ' else ' ONLINE ' end from v$version where banner like 'Oracle%') ||
       'parameters(''replace lexer thema stoplist thema'');' as comando
  from 
      (select i.table_name, i.index_name, 
              i.parameters as lexer,
             (select listAgg(ixv_attribute||'['||ixv_value||']','|') within group (order by ixv_attribute)
                from CTXSYS.CTX_INDEX_VALUES
               where IXV_INDEX_OWNER=i.table_owner 
                 and IXV_INDEX_NAME=i.index_name 
                 and IXV_CLASS='LEXER' 
               group by IXV_INDEX_OWNER, IXV_INDEX_NAME) as preferencesLexer       
         from dba_indexes i
        where i.INDEX_TYPE='DOMAIN' 
          and i.table_owner='ERP')
 WHERE index_name IN ('GRP_TRI_AVERBACAO_CTX_IDX', 'GRP_TRI_RAMOATIVIDADE_CTX');
    


