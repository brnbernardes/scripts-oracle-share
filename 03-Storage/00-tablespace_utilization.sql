-----------------------------
-- Performance dba_free_space
purge dba_recyclebin;
exec DBMS_STATS.GATHER_TABLE_STATS('SYS','X$KTFBUE');

------------------------
-- Tablespaces: Metrics
SELECT tbm.tablespace_name,
       round(tbm.tablespace_size * tb.block_size / (1024 * 1024 * 1024), 2) tablespace_size_gb,
       round(tbm.used_space * tb.block_size / (1024 * 1024 * 1024), 2) used_size_gb,      
       round((tbm.tablespace_size - tbm.used_space) * tb.block_size /
             (1024 * 1024 * 1024), 2) free_size_gb,
       tbm.used_percent
  FROM dba_tablespace_usage_metrics tbm
  JOIN dba_tablespaces tb
    ON tb.tablespace_name = tbm.tablespace_name
--WHERE tb.tablespace_name IN    ('TRIBUTOS', 'TRIBUTOS_IDX', 'AUDITORIA', 'USERS')
ORDER BY used_percent desc;

-----------------------------
-- Tablespaces: Relative Size  
SELECT tablespace_name,
       mb_alloc,
       mb_free_alloc,
       mb_used_alloc,
       pct_free_mb_alloc,
       pct_used_mb_alloc,
       mb_max,
       (mb_max - mb_used_alloc) mb_total_free,
       round((nvl((mb_max - mb_used_alloc), 0) / mb_max) * 100, 2) pct_total_free,
       100 - round((nvl((mb_max - mb_used_alloc), 0) / mb_max) * 100, 2) pct_total_used
  FROM (SELECT tablespace_name,
               mb_alloc,
               mb_free_alloc,
               mb_used_alloc,
               pct_free_mb_alloc,
               pct_used_mb_alloc,
               CASE WHEN mb_max < mb_alloc THEN mb_alloc ELSE mb_max END mb_max
          FROM (SELECT wds_a.tablespace_name tablespace_name,
                       round(wds_a.bytes_alloc / 1024 / 1024, 2) mb_alloc,
                       round(nvl(wds_b.bytes_free, 0) / 1024 / 1024, 2) mb_free_alloc,
                       round((wds_a.bytes_alloc - nvl(wds_b.bytes_free, 0)) / 1024 / 1024,2) mb_used_alloc,
                       round((nvl(wds_b.bytes_free, 0) / wds_a.bytes_alloc) * 100,2) pct_free_mb_alloc,
                       100 - round((nvl(wds_b.bytes_free, 0) / wds_a.bytes_alloc) * 100, 2) pct_used_mb_alloc,
                       round(maxbytes / 1048576, 2) mb_max
                  FROM (SELECT f.tablespace_name,
                               SUM(f.bytes) bytes_alloc,
                               SUM(CASE WHEN maxbytes > bytes THEN maxbytes ELSE bytes END) maxbytes
                          FROM dba_data_files f
                         GROUP BY tablespace_name) wds_a,
                       (SELECT f.tablespace_name, SUM(f.bytes) bytes_free
                          FROM dba_free_space f
                         GROUP BY tablespace_name) wds_b
                 WHERE wds_a.tablespace_name = wds_b.tablespace_name(+)
                UNION
                SELECT wds_h.tablespace_name,
                       round(SUM(wds_h.bytes_free + wds_h.bytes_used) / 1048576, 2),
                       round(SUM((wds_h.bytes_free + wds_h.bytes_used) - nvl(wds_p.bytes_used, 0)) / 1048576, 2),
                       round(SUM(nvl(wds_p.bytes_used, 0)) / 1048576, 2),
                       round((SUM((wds_h.bytes_free + wds_h.bytes_used) - nvl(wds_p.bytes_used, 0)) /
                       SUM(wds_h.bytes_used + wds_h.bytes_free)) * 100, 2),
                       100 - round((SUM((wds_h.bytes_free + wds_h.bytes_used) - nvl(wds_p.bytes_used, 0)) / SUM(wds_h.bytes_used + wds_h.bytes_free)) * 100, 2),
                       round(MAX(wds_h.bytes_used + wds_h.bytes_free) / 1048576, 2)
                  FROM sys.v_$temp_space_header wds_h,
                       sys.v_$temp_extent_pool  wds_p
                 WHERE wds_p.file_id(+) = wds_h.file_id
                   AND wds_p.tablespace_name(+) = wds_h.tablespace_name
                 GROUP BY wds_h.tablespace_name));


------------------------
--Tablespaces: free
WITH tsp AS
 (SELECT tablespace_name,
         SUM(bytes) / 1024 / 1024 tot_mb,
         SUM(greatest(bytes, maxbytes)) / 1024 / 1024 max_mb
    FROM dba_data_files
   GROUP BY tablespace_name),
fs AS
 (SELECT tablespace_name,
         trunc(SUM(bytes) / 1024 / 1024) free_mb,
         trunc(MAX(bytes) / 1024 / 1024) contig_mb
    FROM dba_free_space
   GROUP BY tablespace_name)
SELECT tsp.tablespace_name,
       tot_mb,
       free_mb,
       round(free_mb / tot_mb * 100, 2) "%_FREE",
       max_mb,
       round((max_mb - (tot_mb - free_mb)) / max_mb * 100, 2) "%_MAX_FREE",
       contig_mb
  FROM tsp, fs
 WHERE tsp.tablespace_name = fs.tablespace_name(+)
--AND tsp.tablespace_name = 'SIGAM_DATA'                                                                                                     
 ORDER BY 4;

-----------------------------
--Sensor: ORA Tablespace Free
SELECT a.tablespace_name,
       round(((tam_mb - free_mb) / max_mb) * 100, 2) percent_usado,
       round(max_mb/1024,2)max_gb,
       round(tam_mb/1024,2) tam_gb,
       round(free_mb/1024,2) free_gb
       --round(b.max_size / 1024 / 1024) max_size_tbs_mb,
       --round(b.max_extents / 1024 / 1024) max_extents_tbs_mb
  FROM (SELECT tablespace_name, max_mb, free_mb, tam_mb
          FROM (SELECT tablespace_name,
                       round(SUM(bytes / 1024 / 1024),2) tam_mb,
                       round(SUM(free_bytes / 1024 / 1024),2) free_mb,
                       round(SUM(maxbytes / 1024 / 1024),2) max_mb
                  FROM (SELECT a.tablespace_name,
                               a.bytes,
                               b.free_bytes,
                               CASE
                                 WHEN a.maxbytes < a.user_bytes THEN
                                  a.user_bytes
                                 ELSE
                                  a.maxbytes
                               END maxbytes
                          FROM dba_data_files a,
                               (SELECT tablespace_name,
                                       file_id,
                                       SUM(bytes) free_bytes
                                  FROM dba_free_space
                                 GROUP BY tablespace_name, file_id) b
                         WHERE a.tablespace_name = b.tablespace_name
                           AND a.file_id = b.file_id)
                 GROUP BY tablespace_name)) a,
       dba_tablespaces b
 WHERE a.tablespace_name = b.tablespace_name
   AND b.contents NOT IN ('TEMPORARY', 'UNDO')
   --AND a.tablespace_name LIKE 'AUDITORIA' 
   AND round( ( (tam_mb - free_mb) / max_mb ) * 100, 2) > 87   --SENSOR
 ORDER BY tablespace_name;


--Tablespace
SELECT df.tablespace_name "Tablespace",
       totalusedspace "Used MB",
       (df.totalspace - tu.totalusedspace) "Free MB",
       df.totalspace "Total MB",
       round(100 * ((df.totalspace - tu.totalusedspace) / df.totalspace)) "Pct. Free"
  FROM (SELECT tablespace_name, round(SUM(bytes) / 1048576) totalspace
          FROM dba_data_files
         GROUP BY tablespace_name) df,
       (SELECT round(SUM(bytes) / (1024 * 1024)) totalusedspace,
               tablespace_name
          FROM dba_segments
         GROUP BY tablespace_name) tu
 WHERE df.tablespace_name = tu.tablespace_name
   AND df.totalspace <> 0;
