-- Ajustar trigger de auditoria por table
BEGIN
ERP.ADB$_AUDIT_PACK.recria_trigger(av_owner => 'ERP',av_tabela => 'PRO$_ATENDIMENTO_GRUPO_E');
END;
/

-- Recreate invalid triggers audit
BEGIN
  FOR c IN (SELECT t.owner, t.table_name
              FROM all_objects o
             INNER JOIN all_triggers t
                ON o.owner = t.owner
               AND o.object_name = t.trigger_name
             WHERE o.owner = 'ERP'
               AND o.status <> 'VALID'
               AND o.object_name LIKE 'ADB$%') LOOP
    adb$_audit_pack.recria_trigger(av_owner => c.owner,
                                   av_tabela => c.table_name);
  END LOOP;
END;
/

-- Criar auditoria 
BEGIN
ERP.ADB$_AUDIT_PACK.cria_trigger(av_owner => 'ERP',av_tabela => '&TABELA', av_nome => null, av_trigger => 'T');
END;
/

-- Apagar auditoria
BEGIN
 ERP.ADB$_AUDIT_PACK.apaga_trigger(av_owner => 'ERP',av_tabela => '&TABELA');
END;
/


-- Verificação de auditoria ativa sobre a tabela
SELECT t.owner, trigger_name, table_name, created, last_ddl_time, TIMESTAMP, t.status trigger_status, o.status object_status
  FROM dba_objects o
 INNER JOIN dba_triggers t
    ON o.owner = t.owner
   AND o.object_name = t.trigger_name
 WHERE table_name = '&TABLE'
AND trigger_name like 'ADB$%';