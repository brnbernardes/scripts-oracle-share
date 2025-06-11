-- Actual Size
SELECT component,
       current_size / 1024 / 1024 current_size_mb,
       min_size / 1024 / 1024 min_size_mb,
       max_size / 1024 / 1024 max_size_mb,
       last_oper_time
  FROM v$sga_dynamic_components
WHERE last_oper_time IS NOT NULL;

-- SGA Target: Adivce
SELECT *
  FROM v$sga_target_advice
 ORDER BY estd_physical_reads, estd_db_time;

SELECT inst_id, NAME, round(bytes / 1024 / 1024, 2) mbytes, resizeable
  FROM gv$sgainfo
 ORDER BY 1, 2;