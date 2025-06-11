-- Tables Fragmented
SELECT owner,
       table_name,
       TRUNC(round((blocks * 8), 2) / 1024 / 1024, 2) "SIZE (GB)",
       TRUNC(round((num_rows * avg_row_len / 1024), 2) / 1024 / 1024, 2) "ACTUAL_DATA (GB)",
       (round((blocks * 8), 2) - round((num_rows * avg_row_len / 1024), 2)) / 1024 / 1024 "WASTED_SPACE (GB)",
       tablespace_name
  FROM dba_tables
 WHERE (round((blocks * 8), 2) > round((num_rows * avg_row_len / 1024), 2))
   AND table_name IN
       (SELECT segment_name
          FROM (SELECT owner, segment_name, bytes / 1024 / 1024 meg
                  FROM dba_segments
                 WHERE segment_type = 'TABLE'
                   AND owner = 'ERP'
                   --AND segment_name = '&TABLE_NAME'
                 ORDER BY bytes / 1024 / 1024 DESC)
         WHERE rownum <= 20)
 ORDER BY 5 DESC;


-- Table: Fragment
SELECT table_name,
       round((blocks * 8 / 1024), 2) "SIZE (MB)",
       round((num_rows * avg_row_len / 1024 / 1024), 2) "ACTUAL_DATA (MB)",
       (round((blocks * 8) / 1024, 2) - round((num_rows * avg_row_len / 1024 / 1024), 2)) "WASTED_SPACE (MB)"
  FROM dba_tables
 WHERE  table_name = '&TABLE_NAME'
 ORDER BY 4 DESC;

-- Action: Shrink + MOVE
ALTER TABLE ERP.&TABLE_NAME ENABLE ROW MOVEMENT;     
ALTER TABLE ERP.&TABLE_NAME SHRINK SPACE;    
ALTER TABLE ERP.&TABLE_NAME DISABLE ROW MOVEMENT; 
ALTER TABLE ERP.&TABLE_NAME MOVE  NOLOGGING; 

--Action: Rebuild index, porque estarão inutilizáveis
SELECT 'alter index ' || owner || '.' || index_name || ' rebuild ' ||
       ' tablespace ' || tablespace_name || ' nologging;' cmd,
       index_name,
       tablespace_name,
       status
  FROM dba_indexes
 WHERE table_name = '&TABLE_NAME';


------------------------------------------------------------------------------------------------------------------
-- Show fragmented tables with more than 20% fragmentation and more than 100MB
------------------------------------------------------------------------------------------------------------------


set lines 900
set pagesize 10000
set trimspool on

SELECT *
  FROM (SELECT /*+ RULE */
         t.owner,
         t.table_name,
         s.tablespace_name,
         t.num_rows,
         t.avg_row_len,
         round((greatest(t.num_rows, 1)) * t.avg_row_len / 1024 / 1024) optimal_mb,
         round(s.bytes / 1024 / 1024) actual_mb,
         t.cluster_name cluster_name,
         (SELECT tab.extent_management
            FROM dba_tablespaces tab
           WHERE tab.tablespace_name = s.tablespace_name) extent_management,
         (SELECT tab.segment_space_management
            FROM dba_tablespaces tab
           WHERE tab.tablespace_name = s.tablespace_name) segment_management,
         (SELECT COUNT(*)
            FROM dba_indexes di
           WHERE di.table_owner = t.owner
             AND di.table_name = t.table_name
             AND index_type = 'NORMAL') normal_index,
         (SELECT COUNT(*)
            FROM dba_indexes di
           WHERE di.table_owner = t.owner
             AND di.table_name = t.table_name
             AND index_type = 'BITMAP') bitmap_index,
         (SELECT COUNT(*)
            FROM dba_indexes di
           WHERE di.table_owner = t.owner
             AND di.table_name = t.table_name
             AND index_type = 'FUNCTION-BASED NORMAL') function_index
          FROM dba_tables t, dba_segments s
         WHERE t.owner = s.owner
           AND t.table_name = s.segment_name
           AND t.partitioned = 'NO'
           AND t.owner NOT IN ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP', 'OUTLN','WMSYS', 'EXFSYS', 'PERFMON')
           AND s.bytes / 1024 / 1024 > 100
           AND (nvl(t.avg_row_len, 0) > 1 AND nvl(t.num_rows, 0) > 1)
           AND (((s.bytes / 1024 / 1024) /
               ((greatest(t.num_rows, 1)) * (greatest(t.avg_row_len, 1)) / 1024 / 1024) > 1.25) AND
               ((s.bytes / 1024 / 1024) -
               ((greatest(t.num_rows, 1)) * (greatest(t.avg_row_len, 1)) / 1024 / 1024) > 100))
           AND (t.owner, t.table_name) NOT IN
               (SELECT DISTINCT owner, table_name
                  FROM dba_tab_columns
                 WHERE (data_type LIKE '%LOB' OR data_type LIKE 'LONG'))
         ORDER BY actual_mb DESC)
 WHERE rownum < 21;