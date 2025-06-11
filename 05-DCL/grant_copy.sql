WITH all_grants AS
 (select 'GRANT ' || privilege || ' TO ' || grantee ||
         DECODE(admin_option, 'YES', ' WITH ADMIN OPTION;', ';') as cmd,
         grantee,
         null owner
    from dba_sys_privs
  union
  select 'GRANT ' || granted_role || ' TO ' || grantee ||
         DECODE(admin_option, 'YES', ' WITH ADMIN OPTION;', ';'),
         grantee,
         null
    from dba_role_privs
  where granted_role <> 'DBA'
  union
  select 'GRANT ' || PRIVILEGE || ' ON ' || owner || '.' || table_name ||' TO "' || grantee || '"' ||
         DECODE(grantable, 'YES', ' WITH GRANT OPTION;', ';'),
         grantee,
         owner
    from dba_tab_privs)
SELECT *
  FROM all_grants
 WHERE  owner = '&USER' -- de
 AND grantee <> '&USER'; -- para