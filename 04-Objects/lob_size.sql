-----------------------
--  Lobs from Table
-----------------------
SELECT 
       l.owner,
       l.table_name,
       l.column_name,
       l.segment_name,
       round(SUM(bytes) / 1024 / 1024, 3) Mbytes,
       round(SUM(bytes) / 1024 / 1024 / 1024, 3) gbytes,
       SUM(bytes) bytes,
       l.tablespace_name
  FROM dba_segments s
 INNER JOIN dba_lobs l
    ON s.owner = s.owner
   AND s.segment_name = l.segment_name
 WHERE l.table_name IN ('SOLICITACAO_DIFIN_DEBITOS_EXPORTACAO', 'JZX$_DOCUMENTO_E')
 GROUP BY l.owner, l.table_name, l.column_name, l.segment_name, l.tablespace_name
ORDER BY 1,2,3;
