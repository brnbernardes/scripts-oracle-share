set pages 0
set echo off
set feed off
set long 99999
col cmd for a4000

BEGIN
  DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
  DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
  DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/

SELECT dbms_metadata.get_ddl('INDEX', index_name, owner) cmd
  FROM dba_indexes
 WHERE owner = 'ERP'
   AND index_name = 'BAS$_USUARIO_E';