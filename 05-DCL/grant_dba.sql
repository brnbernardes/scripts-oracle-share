SELECT username,
       account_status,
       PROFILE,
       'revoke ' || granted_role || ' from ' || grantee ||';' "REVOKE",
       'alter user ' || grantee || ' profile default;' "PROFILE"
  FROM dba_role_privs
 INNER JOIN dba_users
    ON username = grantee
 WHERE granted_role = 'DBA'
   AND grantee NOT IN ('SYS', 'SYSTEM', 'SYSMAN', 'WKSYS', 'SYSMAN');
  -- AND grantee NOT LIKE 'DBA%';

SELECT * FROM dba_sys_privs WHERE grantee = 'xxxx' ORDER BY 2;
SELECT * FROM dba_role_privs WHERE grantee = 'xxxx' ORDER BY 2;

GRANT CONNECT TO
GRANT RESOURCE TO
GRANT CREATE VIEW TO
GRANT CREATE MATERIALIZED VIEW TO 
GRANT UNLIMITED TABLESPACE TO 

  
SELECT * FROM dba_profiles WHERE PROFILE ='DEFAULT';   


----------------------------------------------------------------
--REMOVIDOS:

-- PM Caxias do Sul (PRD):
revoke DBA from ADMRHCAMARA;
revoke DBA from ADMRHFAS;
revoke DBA from ADMRHIPAM;

-- PM Esteio (PRD):
revoke DBA from ADMRHWEB;
revoke DBA from ADMRH_HOSPITAL;
revoke DBA from ADMRH_CAMARA;
revoke DBA from ADMRH_RPPS;
revoke DBA from PREV_ESTEIO;

-- PM Gaspar (PRD):
revoke DBA from SIGSAUDEJ;