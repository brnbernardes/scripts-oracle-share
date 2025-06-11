SELECT (SELECT NAME FROM v$pdbs WHERE con_id = u.con_id) pdb,
       username,
       account_status,
       created,
       (SELECT created
          FROM cdb_users
         WHERE con_id = u.con_id
           AND username = 'ERP') erp,
       lock_date,
       expiry_date,
       last_login,
       password_change_date,
       profile
  FROM cdb_users u
 WHERE username LIKE '%@THEMA'
  -- AND account_status <> 'OPEN'
   AND username LIKE 'FERNANDO%'
   --AND trunc(lock_date) = '26/01/2024'
   --AND created <> password_change_date
 ORDER BY USERNAME;


 
SELECT (SELECT NAME FROM v$pdbs WHERE con_id = u.con_id) pdb,
       username,
       account_status,
       created,
       (SELECT created
          FROM cdb_users
         WHERE con_id = u.con_id
           AND username = 'ERP') erp,
       lock_date,
       expiry_date,
       last_login,
       password_change_date,
       profile
  FROM cdb_users u
 WHERE username LIKE '%@THEMA'
   AND account_status <> 'OPEN'
   --AND trunc(lock_date) = '26/01/2024'
   --AND created <> password_change_date
 ORDER BY created;