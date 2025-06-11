SET serveroutput ON
DECLARE
lv_grant VARCHAR2(100);
BEGIN
  FOR c IN (SELECT DISTINCT username
              FROM v$session
             WHERE username LIKE 'ADMRH%'
                   AND upper(program) NOT LIKE 'SQL DEV%'
                   AND upper(program) NOT LIKE 'DBEAVER%'
                   AND upper(program) NOT LIKE 'PLSQLD%')
  LOOP
    BEGIN
      lv_grant := 'GRANT SELECT ON ERP.GRP_CTB_ESOCIALPENSAO_V TO ' || c.username;
      dbms_output.put_line(lv_grant);
      EXECUTE IMMEDIATE lv_grant;
      dbms_output.put_line('OK');    
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
  END LOOP;
END;
/


SELECT listagg(owner || '(' || num_rows || ')', ', ') WITHIN GROUP (ORDER BY owner)  owner
  FROM dba_tables
 WHERE owner IN
       (SELECT username FROM v$session WHERE username LIKE 'ADMRH%')
   AND table_name LIKE 'FUNCIONARIOS'
 ORDER BY 1;