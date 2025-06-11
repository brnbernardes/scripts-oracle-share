SELECT t.owner, t.trigger_name, t.trigger_type, o.last_ddl_time, o.timestamp, t.status
  FROM dba_triggers t
 INNER JOIN dba_objects o
 ON t.owner = o.owner
 AND t.trigger_name = o.object_name
 WHERE t.owner = 'ERP'
   AND t.status <> 'ENABLED';
