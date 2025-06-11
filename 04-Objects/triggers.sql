-- Triggers NO-TABLE
WITH trg AS (
SELECT t.owner || '.' || t.trigger_name "TRIGGER",
       CASE WHEN t.table_name IS NOT NULL THEN (t.table_owner || '.' || t.table_name ) ELSE t.base_object_type END base_object,
       t.triggering_event,
       t.status trigger_status,
       o.status object_status,
       o.last_ddl_time,
       'ALTER TRIGGER ' ||  t.owner || '.' || t.trigger_name || ' DISABLE;' "DISABLE",
       'ALTER TRIGGER ' ||  t.owner || '.' || t.trigger_name || ' ENABLE;' "ENABLE"
  FROM dba_triggers t 
  INNER JOIN dba_objects o 
   ON t.owner = o.owner
  AND t.trigger_name = o.object_name 
 WHERE t.owner IN ('ERP', 'ERP_ADB')
 ) 
SELECT * FROM trg WHERE base_object LIKE 'DATABASE%';