set pages 0
set echo off
set feed off
set long 99999
col cmd for a4000

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT dbms_metadata.get_ddl('PROFILE', PROFILE) cmd FROM 
(SELECT DISTINCT PROFILE FROM dba_profiles WHERE PROFILE <> 'DEFAULT' ORDER BY 1);