SELECT * FROM dba_objects WHERE owner  LIKE 'SYNCDB' AND object_type = 'TABLE';
SELECT * FROM dba_objects WHERE owner LIKE 'SYNCDB' ORDER BY last_ddl_time DESC ;

grant execute on dbms_flashback to dba_thema;
grant flashback any table to dba_thema;
grant flashback on sys.dba_source to dba_thema;

SELECT * FROM sys.dba_source as of timestamp TO_TIMESTAMP('2020-04-07 09:00:00', 'YYYY-MM-DD HH24:MI:SS') WHERE name = 'SDB$_AUDIT_DDL_BT'; 

SELECT * FROM erp.grp_ptl_parametro_e as of timestamp TO_TIMESTAMP('2022-07-11 08:00:00', 'YYYY-MM-DD HH24:MI:SS');

--UTILIZAR NO COMMAND WINDOW DO PL/SQL DEVELOPER
SET lines 999
SET pages 0
SET echo OFF
SET feed OFF
SET term OFF
COL text FOR a9999
--> Note: SPOOL "C:\Users\bruno.bernardes\OneDrive\Documentos\object_backup.sql"
--> Desk: 
SPOOL "C:\Users\Bruno Bernardes\OneDrive\Documentos\Trabalho\object_backup.sql"
SELECT text
  FROM dba_source as of timestamp TO_TIMESTAMP('26-06-2023 16:00:00', 'DD/MM/YYYY HH24:MI:SS')
 WHERE name = 'GRP_CTB_RECEBIMENTO_DOC_PACK'
   AND type = 'PACKAGE BODY'
   AND owner = 'ERP'
 ORDER by line;
SPOOL OFF;