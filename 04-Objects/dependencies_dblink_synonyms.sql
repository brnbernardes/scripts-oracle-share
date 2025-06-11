clear; 
set colsep '|'
set echo on
col host_name for a25
col owner for a15

SELECT inst_id, instance_number, instance_name, host_name, version FROM gv$instance;

SELECT owner, count(1)
  FROM dba_objects
 WHERE owner LIKE 'ERP%'
 GROUP BY owner;
 
col db_link for a30
col username for a25
col host for a15 
SELECT * FROM dba_db_links WHERE owner IN ('ERP', 'PUBLIC') ORDER BY 1, 2;

col synonym_name for a40
col table_owner for a20
col table_name  for a30
SELECT *
  FROM dba_synonyms
 WHERE owner IN ('ERP', 'PUBLIC')
   AND db_link IN
       (SELECT DB_LINK FROM dba_db_links WHERE owner IN ('ERP', 'PUBLIC'))
ORDER BY 1,2,3;
       
col name for a30
col referenced_owner for a20
col referenced_name for a30       
col referenced_link_name for a30
SELECT *
  FROM dba_dependencies
 where referenced_link_name in
       (SELECT DB_LINK FROM dba_db_links WHERE owner IN ('ERP', 'PUBLIC'))
ORDER BY 1,2,3;       
       
       