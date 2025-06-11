---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH dependencies_public as 
(SELECT d.owner,
       d.name,
       d.type,
       table_owner   referenced_owner,
       table_name    referenced_name,
       o.object_type referenced_type
  FROM dba_dependencies d
 INNER JOIN dba_synonyms s
    ON d.referenced_owner = 'PUBLIC'
   AND d.referenced_name = s.synonym_name
 INNER JOIN dba_objects o
    ON o.owner = s.table_owner
   AND object_name = s.table_name)
SELECT * FROM dependencies_public 
WHERE owner = 'ERP' 
AND referenced_owner not in ('SYS', 'XDB', 'LOG4PLSQL', 'ERP', 'CTXSYS');
UNION ALL
SELECT d.owner,
       d.name,
       d.type,
       referenced_owner,
       referenced_name,
       referenced_type
  FROM dba_dependencies d
 WHERE d.referenced_owner = 'ERP'
   AND d.owner <> d.referenced_owner
   AND d.owner NOT IN
       ('ACESSODIRETO', 'ADMRH', 'AGENDAMENTOGRP', 'ERP', 'ERP_ADB',
        'ERP_QLIKVIEW', 'ERP_SELO', 'GRP_CMS', 'HD31', 'LOG4PLSQL',
        'QLIKVIEW', 'THEMA_DESENV');

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT RPAD('-', level*3, '->') || a.referenced_owner || '.' || a.referenced_name AS referenced_object,
       a.referenced_type,
       a.referenced_link_name
FROM   all_dependencies a
WHERE  a.owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_type != 'NON-EXISTENT'
START WITH a.owner = UPPER('ERP')
AND        a.name  IN ('GRP_MAT_REQUISICAO_V', 'GRP_MAT_PRODUTO', 'GRP_MAT_ITEMREQUISICAO_V', 'GRP_MAT_LOCALALMOX_V') --> Views
CONNECT BY a.owner = PRIOR a.referenced_owner
AND        a.name  = PRIOR a.referenced_name
AND        a.type  = PRIOR a.referenced_type;




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Tabelas referenciadas
WITH dp AS
(SELECT
       a.referenced_owner,
       a.referenced_name AS referenced_object,       
       a.referenced_type,
       a.referenced_link_name
FROM   all_dependencies a
WHERE  a.owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_type != 'NON-EXISTENT'
START WITH a.owner = UPPER('ERP')
AND        a.name  IN ('GRP_BAS_ASS_TESTE') --> Views
CONNECT BY a.owner = PRIOR a.referenced_owner
AND        a.name  = PRIOR a.referenced_name
AND        a.type  = PRIOR a.referenced_type)
SELECT t.owner,
       t.table_name,
       t.tablespace_name,
       t.num_rows,
       t.avg_row_len,
       t.blocks,
       t.empty_blocks,
       round(t.blocks * ts.block_size / 1024 / 1024 / 1024, 2) AS size_gb,
       last_analyzed,
       'exec DBMS_STATS.GATHER_TABLE_STATS('''|| t.owner || ''', ''' || t.table_name ||''', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => ''FOR ALL COLUMNS SIZE AUTO'', cascade => TRUE);' cmd
  FROM dba_tables t
  JOIN dba_tablespaces ts
    ON t.tablespace_name = ts.tablespace_name
 WHERE (owner, table_name) IN (SELECT DISTINCT referenced_owner, referenced_object FROM dp WHERE referenced_type = 'TABLE');

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- List Dependences: 1ª degree
SELECT referenced_owner,
       referenced_name,
       referenced_type,
       o.last_ddl_time,
       o.timestamp,
       d.referenced_link_name
  FROM dba_dependencies d
  INNER JOIN dba_objects o
    ON o.owner = d.referenced_owner
   AND o.object_name = d.referenced_name
   AND o.object_type = d.referenced_type
 WHERE d.owner = 'ERP'
   AND d.name = '&OBJECT_NAME'
   AND d.referenced_owner <> 'PUBLIC'
UNION ALL
SELECT o.owner, o.object_name, o.object_type, o.last_ddl_time, o.timestamp, NULL
  FROM dba_dependencies d
 INNER JOIN dba_synonyms s
    ON d.referenced_owner = s.owner
   AND d.referenced_name = s.synonym_name
 INNER JOIN dba_objects o
    ON o.owner = s.table_owner
   AND o.object_name = s.table_name
   AND o.object_type = d.referenced_type
 WHERE d.owner = 'ERP'
   AND d.name = '&OBJECT_NAME'
   AND d.referenced_owner = 'PUBLIC';


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCALIZAR ÁRVORE 
WITH dba_dependencies_mat AS
 (SELECT /*+ materialize */
   NAME, owner, TYPE, referenced_name, referenced_owner, referenced_type
    FROM dba_dependencies
   WHERE owner NOT IN (SELECT DISTINCT SCHEMA FROM dba_registry))

SELECT *
  FROM (SELECT substr(sys_connect_by_path(a.name, ' -> '), 5) tree,
               rpad(' ', LEVEL * 2, ' ') || a.referenced_owner || '.' ||
               a.referenced_name AS referenced_object,
               a.referenced_type
          FROM dba_dependencies_mat a
         WHERE a.owner NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
           AND a.referenced_owner NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
           AND a.referenced_type != 'NON-EXISTENT'
         START WITH a.owner = upper('&owner_obj_pai')
                AND a.name = upper('&name_obj_pai')
        CONNECT BY a.owner = PRIOR a.referenced_owner
               AND a.name = PRIOR a.referenced_name
               AND a.type = PRIOR a.referenced_type) dependencias
 WHERE dependencias.referenced_type LIKE 'TABLE';




------------------------------------------------------------------------------------------------------------------------------------------------------------
-- objetos dependentes recursivos (VIEW -> TABLE)
WITH tmp_dep AS
 (SELECT /*+ materialize */
   NAME, owner, TYPE, referenced_name, referenced_owner, referenced_type
    FROM dba_dependencies
   WHERE owner NOT IN (SELECT DISTINCT SCHEMA FROM dba_registry)),
usedviews(viewname,
viewowner,
viewtype,
interim_name,
interim_owner,
interim_type,
refname,
refowner,
reftype,
lvl) AS
 (SELECT NAME,
         owner,
         TYPE,
         NAME,
         owner,
         TYPE,
         referenced_name,
         referenced_owner,
         referenced_type,
         1 AS lvl
    FROM tmp_dep
   WHERE (owner, NAME) IN (SELECT DISTINCT owner object_owner, object_name
                             FROM dba_objects
                            WHERE object_type = 'VIEW'
                              AND object_name = 'GRP_BAS_MENU_USUARIO_V'
                              AND owner = 'ERP')
     AND referenced_type IN ('TABLE', 'VIEW')
  UNION ALL
  SELECT r.viewname,
         r.viewowner,
         r.viewtype,
         a.name,
         a.owner,
         a.type,
         a.referenced_name,
         a.referenced_owner,
         a.referenced_type,
         r.lvl + 1
    FROM tmp_dep a, usedviews r
   WHERE r.refname = a.name
     AND r.refowner = a.owner
     AND r.reftype = a.type
     AND a.referenced_type IN ('TABLE', 'VIEW')
  
  )
SELECT DISTINCT viewname, viewowner, viewtype, refname, refowner, reftype
  FROM usedviews
 WHERE reftype = 'TABLE'
 GROUP BY viewname, viewowner, viewtype, refname, refowner, reftype
 ORDER BY viewname, viewowner, viewtype, refname, refowner, reftype

------------------------------------------------------------------------------------------------------------------------------------------------------------

