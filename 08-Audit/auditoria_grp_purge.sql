-----------------------------------------------------------
--QUANTIDADE DE REGISTROS POR ANO TABELA ERP.ADB$_AUDIT_E
-----------------------------------------------------------
SELECT to_char(trunc(data, 'YYYY'), 'YYYY') ano, count(1)
  FROM ERP.ADB$_AUDIT_E
 GROUP BY trunc(data, 'YYYY')
 ORDER BY 1;

---------------------------------
--TAMANHO DA TABLESPACE AUDITORIA
---------------------------------
SELECT tablespace_name,
       round(sum(bytes) / 1024 / 1024/1024, 2) size_gb
  FROM dba_segments
 WHERE tablespace_name = 'AUDITORIA'
 GROUP BY tablespace_name;

--------------------------------------
--TAMANHO OBJETOS TABLESPACE AUDITORIA
--------------------------------------
SELECT tablespace_name,
       owner,
       segment_type,
       segment_name,
       round(sum(bytes) / 1024 / 1024, 2) size_mb,       
       round(sum(bytes) / 1024 / 1024 / 1024, 2) size_gb
  FROM dba_segments
 WHERE tablespace_name = 'AUDITORIA'
 GROUP BY owner, segment_type, segment_name, tablespace_name
 ORDER BY size_mb DESC;

-------------------------------
-- TAMANHO TABLESAPCE AUDITORIA
-------------------------------
SELECT a.tablespace_name,
       round(((tam_mb - free_mb) / max_mb) * 100, 2) percent_usado,
       max_mb,
       tam_mb,
       free_mb,
       round(b.max_size / 1024 / 1024) max_size_tbs_mb,
       round(b.max_extents / 1024 / 1024) max_extents_tbs_mb
  FROM (SELECT tablespace_name, max_mb, free_mb, tam_mb
          FROM (SELECT tablespace_name,
                       round(SUM(user_bytes / 1024 / 1024)) tam_mb,
                       round(SUM(free_bytes / 1024 / 1024)) free_mb,
                       round(SUM(maxbytes / 1024 / 1024)) max_mb
                  FROM (SELECT a.tablespace_name,
                               a.user_bytes,
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
   AND a.tablespace_name = 'AUDITORIA'
 ORDER BY tablespace_name;

--------------------------------------------
--TAMANHO DATAFILES DA TABLESPACE AUDITORIA
--------------------------------------------
select tablespace_name, 
       file_id,
       file_name,
       blocks,
       autoextensible,
       round(increment_by * 8 /1024, 2) "INCREMENT_BY (MB)",
       round(bytes / 1024 / 1024/ 1024) "SIZE (GB)",
       round(maxbytes / 1024 / 1024 / 1024) "MAX (GB)",
       case when bytes > maxbytes then round(bytes/1024/1024,2) else round(maxbytes/1024/1024, 2) end limited_mb 
       --'alter database datafile ''' || file_name || ''' AUTOEXTEND ON NEXT 100M MAXSIZE 33554400K;' alter_limited
  from dba_data_files
 WHERE tablespace_name = 'AUDITORIA'
 order by 1,2;