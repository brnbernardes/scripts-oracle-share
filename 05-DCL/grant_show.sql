-- Grants: Objects ERP other USERS
SELECT "GRANTEE", "SELECT", "EXECUTE", "INSERT", 
       "DELETE", "UPDATE", "REFERENCES"  
FROM 
(SELECT grantee, privilege, COUNT(1) qtd
  FROM dba_tab_privs
 WHERE owner = 'ERP'
 AND grantee NOT LIKE '%@THEMA'
 AND grantee NOT LIKE 'BAS$_USUARIO%'
 GROUP BY grantee, PRIVILEGE)
PIVOT(SUM(qtd) FOR PRIVILEGE IN('SELECT' "SELECT",'EXECUTE' "EXECUTE", 'INSERT' "INSERT", 
                                'DELETE' "DELETE", 'UPDATE' "UPDATE",  'REFERENCES' "REFERENCES" ))
ORDER BY 1
/


SELECT * FROM dba_sys_privs WHERE grantee = '&GRANTEE';

SELECT * FROM dba_role_privs WHERE grantee = '&GRANTEE';

SELECT grantee,
       owner || '.' || table_name AS object_name,
       privilege,
       grantor
  FROM dba_tab_privs
 WHERE grantee = '&GRANTEE'
 AND owner = 'ERP';