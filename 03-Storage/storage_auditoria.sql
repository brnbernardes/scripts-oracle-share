------------------------------
--Storage: Auditoria no ERP
------------------------------
WITH objects_audit AS
( SELECT s.owner,
       s.segment_type,
       s.segment_name,
       round(sum(s.bytes / 1024 / 1024 / 1024), 2) size_gb
  FROM dba_segments s
 WHERE s.owner = 'ERP'
   AND s.segment_name IN ('ADB$_LOGIN_E',
                      'ADB$_TABELAPROGRAMA_E',
                      'ADB$_PROGRAM_E',
                      'ADB$_AUDIT_DDL_E',
                      'BAS$_AUDITORIA_ERRO_SISTEMA_E',
                      'BAS$_AUDITORIA_REGISTRO_E',
                      'BAS$_AUDITORIA_ACESSO_E',
                      'BAS$_AUDITORIA_ACESSO_PROG_E',
                      'ADB$_AUDIT_PROCEDURE_E',
                      'ADB$_USER_SESSION_E',
                      'ADB$_AUDIT_E',
                      'GRP_ADB_CONSULTA_ACESSO_PROG_E',
                      'GRP_ADB_CONSULTA_EVENTOS_E',
                      'GRP_ADB_CONSULTA_TABELAS_E',
                      'GRP_ADB_CONSULTA_USUARIOS_E')
 GROUP BY s.owner, s.segment_type, s.segment_name
UNION ALL
SELECT s.owner,
       s.segment_type,
       s.segment_name,
       round(sum(s.bytes / 1024 / 1024 / 1024), 2) size_gb
  FROM dba_segments s
 INNER JOIN dba_indexes i
    ON s.owner = i.owner
   AND s.segment_name = i.index_name
 WHERE table_owner = 'ERP'
   AND table_name IN ('ADB$_LOGIN_E',
                      'ADB$_TABELAPROGRAMA_E',
                      'ADB$_PROGRAM_E',
                      'ADB$_AUDIT_DDL_E',
                      'BAS$_AUDITORIA_ERRO_SISTEMA_E',
                      'BAS$_AUDITORIA_REGISTRO_E',
                      'BAS$_AUDITORIA_ACESSO_E',
                      'BAS$_AUDITORIA_ACESSO_PROG_E',
                      'ADB$_AUDIT_PROCEDURE_E',
                      'ADB$_USER_SESSION_E',
                      'ADB$_AUDIT_E',
                      'GRP_ADB_CONSULTA_ACESSO_PROG_E',
                      'GRP_ADB_CONSULTA_EVENTOS_E',
                      'GRP_ADB_CONSULTA_TABELAS_E',
                      'GRP_ADB_CONSULTA_USUARIOS_E')
 GROUP BY s.owner, s.segment_type, s.segment_name
UNION ALL
SELECT s.owner,
       s.segment_type,
       s.segment_name,
       round(sum(s.bytes / 1024 / 1024 / 1024), 2) size_gb
  FROM dba_lobs l
 INNER JOIN dba_segments s
    ON l.owner = s.owner
   AND l.segment_name = s.segment_name
 WHERE l.owner = 'ERP'
   AND l.table_name IN ('ADB$_LOGIN_E',
                      'ADB$_TABELAPROGRAMA_E',
                      'ADB$_PROGRAM_E',
                      'ADB$_AUDIT_DDL_E',
                      'BAS$_AUDITORIA_ERRO_SISTEMA_E',
                      'BAS$_AUDITORIA_REGISTRO_E',
                      'BAS$_AUDITORIA_ACESSO_E',
                      'BAS$_AUDITORIA_ACESSO_PROG_E',
                      'ADB$_AUDIT_PROCEDURE_E',
                      'ADB$_USER_SESSION_E',
                      'ADB$_AUDIT_E',
                      'GRP_ADB_CONSULTA_ACESSO_PROG_E',
                      'GRP_ADB_CONSULTA_EVENTOS_E',
                      'GRP_ADB_CONSULTA_TABELAS_E',
                      'GRP_ADB_CONSULTA_USUARIOS_E')
 GROUP BY s.owner, s.segment_type, s.segment_name)
SELECT owner, segment_type,  sum(size_gb) size_gb FROM objects_audit GROUP BY owner, segment_type;

--------------
-- Datafiles
WITH datafiles AS (
select tablespace_name, 
      file_id,
      --file_name,
      substr(file_name, 1, instr(file_name, '/',+2)-1) unidade_name,
      substr(file_name, 1, instr(file_name, '/',-1)) path_name,
      substr(file_name, instr(file_name, '/',-1)+1) datafile_name,
      blocks,
      autoextensible,
      round(increment_by * 8 /1024, 2) increment_by_mb,
      round(bytes / 1024 / 1024/ 1024, 2)  size_gb,
      round(maxbytes / 1024 / 1024 / 1024, 2) max_gb,
      case when bytes > maxbytes then round(bytes/1024/1024/1024,2) else round(maxbytes/1024/1024/1024, 2) end limited_gb, 
      'alter database datafile ''' || file_name || ''' AUTOEXTEND ON NEXT 256M MAXSIZE UNLIMITED;' alter_limited, --33554416K
      'alter database datafile ''' || file_name || ''' AUTOEXTEND OFF;' autoextend_off
  from dba_data_files
order by 1,2)
select * from datafiles WHERE tablespace_name = 'AUDITORIA'; 

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