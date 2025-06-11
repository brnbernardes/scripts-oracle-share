SET COLSEP ' | '
COL lob_table_column FOR a40
 WITH segmentos AS
   (SELECT tablespace_name,
           owner || '.' || segment_name segment_name,
           segment_type,
           CASE
             WHEN segment_type = 'LOBSEGMENT' THEN
              (SELECT table_name || ' -> ' || column_name
                 FROM dba_lobs l
                WHERE l.owner = s.owner
                  AND l.segment_name = s.segment_name)
             WHEN segment_type = 'LOBINDEX' THEN
              (SELECT table_name
                 FROM dba_indexes i
                WHERE i.owner = s.owner
                  AND i.index_name = s.segment_name)
             ELSE
              NULL
           END lob_table_column,
           round(SUM(bytes) / 1024 / 1024 / 1024, 2) gbytes
      FROM dba_segments s
     WHERE tablespace_name IN ('AUDITORIA')
     GROUP BY owner, segment_name, tablespace_name, segment_type
      ORDER BY gbytes DESC)
 SELECT * FROM segmentos WHERE gbytes > 1;