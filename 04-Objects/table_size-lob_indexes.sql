-------------------------------
--Size: Table | Lobs | Indexes
WITH segment_table AS
 (SELECT s.owner,
         s.segment_name table_name,
         s.tablespace_name,
         SUM(bytes) bytes
    FROM dba_segments s
   WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP')
     AND s.segment_type = 'TABLE'
   GROUP BY s.owner, s.segment_name, s.tablespace_name),
segment_lob AS
 (SELECT l.owner, l.table_name, l.tablespace_name, SUM(s.bytes) bytes
    FROM dba_segments s
   INNER JOIN dba_lobs l
      ON s.owner = l.owner
     AND s.segment_name = l.segment_name
   WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP')
   GROUP BY l.owner, l.table_name, l.tablespace_name),
segment_index AS
 (SELECT i.owner, i.table_name, i.tablespace_name, SUM(s.bytes) bytes
    FROM dba_segments s
   INNER JOIN dba_indexes i
      ON s.owner = i.owner
     AND s.segment_name = i.index_name
   WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP')
   GROUP BY i.owner, i.table_name, i.tablespace_name)
SELECT *
  FROM (SELECT t.owner,
               t.table_name,
               tb.num_rows table_num_rows,
               tb.last_analyzed table_last_analyzed,
               t.tablespace_name table_tablespace,
               round((t.bytes / 1024 / 1024 / 1024), 2) table_size_gb,
               l.tablespace_name lob_tablespace,
               round((nvl(l.bytes, 0) / 1024 / 1024 / 1024), 2) lob_size_gb,
               i.tablespace_name index_tablespace,
               round((nvl(i.bytes, 0) / 1024 / 1024 / 1024), 2) indexes_size_gb
          FROM dba_tables tb
         INNER JOIN segment_table t
            ON t.owner = tb.owner
           AND t.table_name = tb.table_name
          LEFT JOIN segment_index i
            ON t.owner = i.owner
           AND t.table_name = i.table_name
          LEFT JOIN segment_lob l
            ON t.owner = l.owner
           AND t.table_name = l.table_name
         ORDER BY table_size_gb DESC)
 WHERE table_name = 'ADB$_AUDIT_E';


----------------
-- Table: show
SELECT t.table_name,
       t.tablespace_name,
       t.num_rows,
       t.avg_row_len,
       t.blocks,
       t.empty_blocks,
       ROUND(t.blocks * ts.block_size/1024/1024/1024,2) AS size_gb,
       (round((t.blocks*8/1024/1024),2) - round((t.num_rows*t.avg_row_len/1024)/1024/1024,2)) WASTED_SPACE_GB,
       last_analyzed
FROM   dba_tables t
       JOIN dba_tablespaces ts ON t.tablespace_name = ts.tablespace_name
WHERE  t.owner = 'ERP'
AND t.table_name = 'MAT$_PRODUTO_SALDO_MENSAL_E'
ORDER BY t.table_name;


----------------------
--Size: Tables + Lobs 
WITH segment_table AS
 (SELECT owner, table_name, tablespace_name, sum(bytes) bytes
    FROM (SELECT s.owner,
                 s.segment_name table_name,
                 s.tablespace_name,
                 s.bytes
            FROM dba_segments s
           WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP')
             AND s.segment_type = 'TABLE'
          UNION ALL
          SELECT s.owner, l.table_name, s.tablespace_name, s.bytes
            FROM dba_segments s
           INNER JOIN dba_lobs l
              ON s.owner = l.owner
             AND s.segment_name = l.segment_name
           WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP'))
   GROUP BY owner, table_name, tablespace_name),
segment_index AS
 (SELECT i.owner, i.table_name, sum(s.bytes) bytes
    FROM dba_segments s
   INNER JOIN dba_indexes i
      ON s.owner = i.owner
     AND s.segment_name = i.index_name
   WHERE s.owner NOT IN ('SYS', 'SYSTEM', 'DBSNMP')
   GROUP BY i.owner, i.table_name)
SELECT *
  FROM (SELECT t.owner,
               t.table_name,
               t.tablespace_name table_tablespace_name,
               round((t.bytes / 1024 / 1024 / 1024), 2) table_size_gb,
               tb.num_rows table_num_rows,
               tb.last_analyzed table_last_analyzed,
               round((nvl(i.bytes, 0) / 1024 / 1024 / 1024), 2) indexes_size_gb
          FROM segment_table t
         INNER JOIN dba_tables tb
            ON t.owner = tb.owner
           AND t.table_name = tb.table_name
          LEFT JOIN segment_index i
            ON t.owner = i.owner
           AND t.table_name = i.table_name
         ORDER BY table_size_gb DESC)
 WHERE table_size_gb >= 1
 AND table_name = 'ADB$_AUDIT_E';

---------
--Check
SELECT s.owner,
       nvl(s.segment_name, 'TABLE TOTAL SIZE') segment_name,
       round(SUM(s.bytes) / 1024 / 1024 / 1024, 1) size_gb
  FROM dba_segments s
 WHERE (s.segment_name IN ('ADB$_AUDIT_E') AND s.owner = 'ERP')
    OR s.segment_name IN ((SELECT l.segment_name
                            FROM dba_lobs l
                           WHERE l.table_name = s.segment_name
                             AND l.owner = s.owner))
 GROUP BY s.owner, ROLLUP(s.segment_name)
 ORDER BY 1, 2, 3;
