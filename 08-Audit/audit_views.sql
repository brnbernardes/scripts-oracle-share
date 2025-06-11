SELECT username,
       owner,
       obj_name,
       action_name,
       to_date(to_char(TIMESTAMP, 'dd/mm/yyyy'), 'dd/mm/yyyy') DATA,
       COUNT(1)
  FROM dba_audit_object
 GROUP BY username,
          owner,
          obj_name,
          action_name,
          to_date(to_char(TIMESTAMP, 'dd/mm/yyyy'), 'dd/mm/yyyy') 
ORDER BY data;


SELECT COUNT(1) FROM sys.aud$;

--> Regras
SELECT * FROM dba_obj_audit_opts;
SELECT * FROM dba_priv_audit_opts;
SELECT * FROM dba_stmt_audit_opts;

SELECT * FROM dba_audit_object;
SELECT * FROM dba_audit_statement;
SELECT * FROM dba_audit_policies;
SELECT * FROM dba_audit_policy_columns;
SELECT * FROM dba_audit_exists;
SELECT * FROM dba_audit_session;

SELECT * FROM dba_audit_mgmt_last_arch_ts;



NOAUDIT SELECT ON ERP.BAS$_CADASTROGERAL_E;
NOAUDIT SELECT ON ERP.CADASTROGERAL;
