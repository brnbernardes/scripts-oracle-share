PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : TABLE Fragmentation                                         |
PROMPT +------------------------------------------------------------------------+
PROMPT 
COL owner FOR a10
COL table_name FOR a20
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_user NEW_VALUE current_user NOPRINT;
SELECT rpad(instance_name, 17) current_instance, rpad(user, 13) current_user FROM v$instance;
SET TERMOUT ON;
SELECT owner,
       table_name,
       tablespace_name,
       TRUNC(round((blocks * 8), 2) / 1024 / 1024, 2) "SIZE (GB)",
       TRUNC(round((num_rows * avg_row_len / 1024), 2) / 1024 / 1024, 2) "ACTUAL_DATA (GB)",
       ROUND((round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) / 1024 / 1024,2) "WASTED_SPACE (GB)",
       ROUND(((round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) / 1024 / 1024)
       * 100 /
       (round((blocks * 8), 2) / 1024 / 1024), 2) || ' %' "FRAGMENTATION"
  FROM dba_tables
 WHERE (round((blocks * 8), 2) > round((num_rows * avg_row_len / 1024), 2))
   AND table_name IN
       (SELECT segment_name
          FROM (SELECT owner, segment_name, bytes / 1024 / 1024 meg
                  FROM dba_segments
                 WHERE segment_type = 'TABLE'
                   AND owner = 'ERP_ADB'
                  AND segment_name = 'ADB$_AUDIT_E'
                 ORDER BY bytes / 1024 / 1024 DESC)
         WHERE rownum <= 20)
 ORDER BY 5 DESC;