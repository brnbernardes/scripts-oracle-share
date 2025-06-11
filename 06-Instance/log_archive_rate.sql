SELECT *
  FROM (SELECT thread#,
               sequence#,
               first_time "LOG_START_TIME",
               l.completion_time "LOG_FINISH_TIME",
               round((blocks * block_size / 1024 / 1024) /
                     ((next_time - first_time) * 86400), 0) "REDO RATE(MB/s)",
               round((blocks * block_size) / 1024 / 1024) "SIZE_MB",
               round((((blocks * block_size) / a.average) * 100), 2) pct_full
          FROM v$archived_log l , (SELECT AVG(bytes) average FROM v$log) a
         WHERE ((next_time - first_time) * 86400 < 300)
           AND first_time > (SYSDATE - 90)
           AND (((blocks * block_size) / a.average) * 100) > 50
           AND dest_id = 1
         ORDER BY 5)
 WHERE rownum < 30;


-- Coletar o Rate de acordo com a taxa
SELECT thread#,
       sequence#,
       blocks * block_size / 1024 / 1024 mb,
       (next_time - first_time) * 86400 sec,
       (blocks * block_size / 1024 / 1024) /
       ((next_time - first_time) * 86400) "MB/s"
  FROM v$archived_log
 WHERE ((next_time - first_time) * 86400 <> 0)
   AND first_time BETWEEN to_date('2024/05/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS') --> alterar data de início da verificação
   AND to_date('2024/05/20 19:00:00', 'YYYY/MM/DD HH24:MI:SS') --> alterar data final da verificação
   AND dest_id = 1
 ORDER BY first_time;
