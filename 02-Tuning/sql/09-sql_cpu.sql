-- CPU
SELECT *
  FROM (SELECT (SELECT NAME FROM v$pdbs WHERE con_id = s.con_id) NAME,
               sql_id,
               (SELECT command_name FROM v$sqlcommand WHERE command_type = s.command_type) commnand,
               sql_text,
               executions,
               rows_processed,
               rows_processed / executions "Rows/Exec",
               disk_reads,
               round(((cpu_time / 1000000) / 60), 2) "CPU (Minutes)",
               s.last_load_time
          FROM v$sqlarea s
         WHERE executions > 100
         ORDER BY round(((cpu_time / 1000000) / 60), 2)  DESC)
WHERE ROWNUM <= 50;