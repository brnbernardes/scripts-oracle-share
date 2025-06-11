SELECT t.owner,
       t.trigger_name,
       t.table_name,
       t.status,
       o.last_ddl_time,
       o.timestamp,
       'ALTER TRIGGER ' || t.owner || '.' || trigger_name || ' ENABLE;' ENABLE
  FROM dba_triggers t
 INNER JOIN dba_objects o
    ON t.owner = o.owner
   AND t.trigger_name = o.object_name
 WHERE t.owner = 'ERP'
   AND t.status = 'DISABLED'
   AND last_ddl_time >= trunc(SYSDATE)
 ORDER BY last_ddl_time;
