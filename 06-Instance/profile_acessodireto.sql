SELECT u.username,
       profile,
       resource_type,
       resource_name,
       LIMIT
  FROM dba_users u
 INNER JOIN dba_profiles p
 USING (profile)
 WHERE username = 'ACESSODIRETO'
   AND resource_type = 'KERNEL';