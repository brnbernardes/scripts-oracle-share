------------------------
-- Tablespaces @ CDB
SELECT 
       (SELECT name FROM v$pdbs WHERE con_id = tbm.con_id) pdb,
       tbm.tablespace_name,
       round(tbm.tablespace_size * tb.block_size / (1024 * 1024 * 1024), 2) tablespace_size_gb,
       round(tbm.used_space * tb.block_size / (1024 * 1024 * 1024), 2) used_size_gb,      
       round((tbm.tablespace_size - tbm.used_space) * tb.block_size /
             (1024 * 1024 * 1024), 2) free_size_gb,
       tbm.used_percent
  FROM cdb_tablespace_usage_metrics tbm
  JOIN cdb_tablespaces tb
    ON tb.tablespace_name = tbm.tablespace_name
    AND tb.con_id = tbm.con_id
ORDER BY used_percent DESC;