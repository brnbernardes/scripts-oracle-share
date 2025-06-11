-- Views com Triggers
SELECT * FROM (
SELECT t.table_name view_name, t.trigger_name
  FROM dba_objects o
 INNER JOIN dba_triggers t
    ON o.owner = t.owner
   AND o.object_name = t.table_name
 WHERE o.owner = 'ERP' 
 AND o.object_type = 'VIEW')
 WHERE view_name = 'GRP_BAS_LOCALIZACAO_COMPLETA';