set pages 0
set echo off
set feed off
set long 9999
col cmd for a4000

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT REPLACE(dbms_metadata.get_ddl('TRIGGER', trigger_name, owner),'EDITIONABLE ', NULL) cmd
  FROM dba_triggers
 WHERE table_owner = 'ERP_ADB'
   AND owner = 'ERP';
