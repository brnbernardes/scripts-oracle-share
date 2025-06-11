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

SELECT DISTINCT 'CREATE BIGFILE TABLESPACE ' || tablespace_name ||
                ' DATAFILE ''+DATA''' ||
                ' size 10M autoextend on maxsize unlmited;' cmd
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT DISTINCT tablespace_name
                             FROM dba_segments)
 ORDER BY 1;
