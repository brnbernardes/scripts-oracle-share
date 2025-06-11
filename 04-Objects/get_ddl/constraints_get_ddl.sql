set pages 0
set echo off
set feed off
col cmd for a4000

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/


-- GET PK
 SELECT constraint_name,
       dbms_metadata.get_ddl('CONSTRAINT', constraint_name) ddl
  FROM dba_constraints
 WHERE owner = 'ERP'
   AND constraint_name = 'TIMT_PK';

-- GET FK
 SELECT constraint_name,
       dbms_metadata.get_ddl('REF_CONSTRAINT', constraint_name) ddl
  FROM dba_constraints
 WHERE owner = 'ERP'
   AND constraint_name = '&FK';

-- GET FK PELA PK
SELECT constraint_name,
       dbms_metadata.get_ddl('REF_CONSTRAINT', constraint_name) ddl
  FROM dba_constraints
 WHERE r_owner = 'ERP'
   AND r_constraint_name = '&PK';



