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
select * from datafiles WHERE tablespace_name = 'ADMRH'; 

--ADD DATAFILE
--alter tablespace USERS add datafile '/ora2/oracle/oradata/tjal/users03.dbf' SIZE 5g AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED;
--alter tablespace JASIX add datafile '/u01/app/oracle/oradata/pmcs/jasix03.dbf' SIZE 256M AUTOEXTEND ON NEXT 256M MAXSIZE UNLIMITED;
--alter tablespace CMS add datafile '/u01/app/oracle/oradata/HMLDB/pmvenancioh/CMS_02.dbf' SIZE 256M AUTOEXTEND ON NEXT 256M MAXSIZE UNLIMITED;

----------------
--Total Fisico
select round(sum(bytes)/1024/1024/1024, 2) "SIZE (GB)", round(sum(bytes/1024/1024/1024/1024),2) "SIZE (TB)" from dba_data_files;

SELECT round(SUM(total_size) / 1024 / 1024 / 1024, 2) "Size_Disk (GB)"
  FROM (SELECT SUM(bytes) AS total_size
          FROM dba_data_files
        UNION ALL
        SELECT SUM(bytes)
          FROM dba_temp_files
        UNION ALL
        SELECT SUM(block_size * file_size_blks)
          FROM v$controlfile
        UNION ALL
        SELECT SUM(bytes)
          FROM v$log l, v$logfile f
         WHERE l.group# = f.group#
        UNION ALL
        SELECT SUM(bytes)
          FROM v$standby_log l, v$logfile f
         WHERE l.group# = f.group#);


---------------------------
-- Total Lógico (Segments)
WITH armazenamento AS
   (SELECT tablespace_name, owner, round(SUM(bytes) / 1024 / 1024) mbytes
      FROM dba_segments
     WHERE tablespace_name = 'USERS'
     GROUP BY tablespace_name, owner)
  SELECT * FROM armazenamento WHERE mbytes > 100;

SELECT owner, round(sum(bytes/1024/1024/1024),2) SIZE_GB
from (
select CASE
         WHEN owner NOT IN ('ERP', 'ERP_ADB', 'GRP_CMS') AND owner NOT LIKE 'ADMRH%' THEN
          'OTHERS'
         ELSE
          owner
       END owner,
       bytes 
  from dba_segments
) GROUP BY owner
ORDER BY 1 ;

SELECT owner, round(sum(bytes/1024/1024/1024),2) SIZE_GB
from (
select owner,
       bytes 
  from dba_segments
) GROUP BY owner
ORDER BY 2 DESC;

------------------------
--Total por unidade SO
 SELECT substr(file_name, 1, instr(file_name, '/', +2) - 1) unidade_name,
           round(sum(bytes / 1024 / 1024 / 1024), 2) size_gb,
           round(sum(case
                       when bytes < maxbytes and autoextensible = 'YES' then maxbytes
                     else bytes
                     end / 1024 / 1024 / 1024),
                 2) maxbytes_gb
      FROM dba_data_files
    GROUP BY substr(file_name, 1, instr(file_name, '/', +2) - 1);

col unidade_name for a30
col path_name for a40
SELECT 
       substr(file_name, 1, instr(file_name, '/',+2)-1) unidade_name,
       substr(file_name, 1, instr(file_name, '/',-1)) path_name,
       round(sum(bytes / 1024 / 1024 / 1024), 2) size_gb
FROM dba_data_files
GROUP BY file_name;   

SELECT substr(file_name, 1, instr(file_name, '/', +2) - 1) unidade_name,
           round(sum(bytes / 1024 / 1024 / 1024), 2) size_gb
      FROM dba_data_files
    GROUP BY substr(file_name, 1, instr(file_name, '/', +2) - 1);


---------------------------------------
--Distriuicao Objetos entre datafiles
select tablespace_name, segment_name, file_id, file_name, round( bytes/1024/1024 ) mbytes,
          round( ratio_to_report(bytes) over () * 100, 2 ) pct
     from (
  select sum(a.bytes) bytes, b.file_name, a.segment_name, a.tablespace_name, b.file_id
     from dba_extents a, 
          dba_data_files b
   where a.owner = 'ERP'
      and a.segment_name = '&TABLE'
      and a.segment_type = 'TABLE'
     and a.file_id = b.file_id
 group by a.tablespace_name, a.segment_name, b.file_name, b.file_id
         )
 order by file_name;

---------------------------------------
--List Datafiles (terminal)
column tablespace_name	format a20;
column file_name	format a60;
column mbytes		format 9999990;
column free		format 9999990;
column used		format 9999990;
column maxsize		format 9999990;
column auto_inc		format 99990;
column "% FREE"         format 990D0;
break on report;
compute sum of mbytes	on report;
compute sum of free	on report;
compute sum of used	on report;
SET feedback OFF;
variable bs number;
BEGIN
  SELECT VALUE INTO :bs FROM v$parameter WHERE NAME = 'db_block_size';
END;
/ 
SET feedback ON;
SELECT a.tablespace_name,
       a.file_name,
       a.bytes / 1048576 mbytes,
       nvl(SUM(b.bytes), 0) / 1048576 free,
       (nvl(SUM(b.bytes), 0) / a.bytes * 100) AS "% FREE",
       (a.bytes - nvl(SUM(b.bytes), 0)) / 1048576 used,
       trunc(a.maxbytes / 1048576) maxsize,
       a.autoextensible,
       (a.increment_by * :bs / 1048576) auto_inc,
       a.status
  FROM dba_data_files a, dba_free_space b
 WHERE b.file_id(+) = a.file_id
 GROUP BY a.tablespace_name,
          a.file_name,
          a.bytes,
          a.status,
          a.autoextensible,
          a.maxbytes,
          a.increment_by
UNION
SELECT a.tablespace_name,
       a.file_name,
       a.bytes / 1048576 mbytes,
       SUM(b.bytes) / 1048576 free,
       (SUM(b.bytes) / a.bytes * 100) AS "% FREE",
       (a.bytes - SUM(b.bytes)) / 1048576 used,
       trunc(a.maxbytes / 1048576) maxsize,
       a.autoextensible,
       (a.increment_by * :bs / 1048576) auto_inc,
       a.status
  FROM dba_temp_files a, dba_free_space b
 WHERE b.file_id = a.file_id
 GROUP BY a.tablespace_name,
          a.file_name,
          a.bytes,
          a.status,
          a.autoextensible,
          a.maxbytes,
          a.increment_by
 ORDER BY 1, 2;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
prompt Tamanho total físico do BD, considerando datafiles e tempfiles:
SELECT round(SUM(used.bytes) / 1024 / 1024 / 1024) || ' GB' "Database Size",
       round(free.p / 1024 / 1024 / 1024) || ' GB' "Free space"
  FROM (SELECT bytes FROM v$datafile UNION ALL SELECT bytes FROM v$tempfile) used,
       (SELECT SUM(bytes) AS p FROM dba_free_space) free
 GROUP BY free.p;


prompt
prompt Total lógico do BD:
 select (sum(bytes)/1024/1024/1024) as size_gb 
     from dba_segments;

prompt  
prompt Totalizadores das tablespaces:
 SELECT      d.tablespace_name "Name",
                 d.status "Status",
                 a.bytes/ 1024 / 1024 "TOTAL(M)",
                 F.bytes / 1024 / 1024 "LIVRE(M)",
      ((a.bytes - DECODE(f.bytes, NULL, 0, f.bytes)) / 1024 / 1024) "ALOCADO(M)",
                 d.block_size
     FROM        sys.dba_tablespaces d, 
                 sys.sm$ts_avail a, 
                 sys.sm$ts_free f
     WHERE       d.tablespace_name = a.tablespace_name 
     AND         f.tablespace_name (+) = d.tablespace_name
     ORDER BY    3 DESC;
 
prompt
prompt Total lógico das  tabelas:
select  (sum(bytes)/1024/1024/1024) as size_gb 
     from    dba_segments 
     where   segment_type in ('TABLE SUBPARTITION','TABLE PARTITION','TABLE');

prompt
prompt Total lógico dos índices:
select  (sum(bytes)/1024/1024/1024) as size_gb 
     from    dba_segments 
     where   segment_type IN ('INDEX PARTITION','INDEX');