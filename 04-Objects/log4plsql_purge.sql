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
      'alter database datafile ''' || file_name || ''' AUTOEXTEND ON NEXT 100M MAXSIZE 33554416K;' alter_limited
  from dba_data_files
order by 1,2)
select * from datafiles WHERE tablespace_name = 'USERS'; 


SELECT owner, segment_name, round(SUM(bytes) / 1024 / 1024, 2) mbytes
  FROM dba_segments
 WHERE tablespace_name = 'USERS'
 GROUP BY owner, segment_name
ORDER BY 3 DESC;

--Size Tables + Lobs 
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
 AND table_name = 'TLOG';


SELECT DISTINCT owner || '.' || NAME
  FROM dba_source
 WHERE owner = 'ERP'
   AND (upper(text) LIKE '%PLOG.ERROR%'
    OR upper(text) LIKE '%PLOG.LOG%')
   AND upper(text) NOT LIKE '%--%PLOG%'


SELECT * FROM dba_directories;

TRUNCATE TABLE log4plsql.tlog;
SELECT * FROM log4plsql.tlog;


grant CREATE JOB to LOG4PLSQL; 

BEGIN
  dbms_scheduler.create_job(
							job_name 		    => 'LOG4PLSQL.LOG4PLSQL_PURGE',
							job_type		    => 'PLSQL_BLOCK',
							job_action		  => 'DECLARE plogctx log4plsql.plog.log_ctx := plog.init; pdata DATE := SYSDATE - 90; BEGIN log4plsql.plog.purge(plogctx, pdata); COMMIT; END;',
							start_date		  => systimestamp,
							end_date		    => null,
							repeat_interval	=> 'FREQ=DAILY; BYHOUR=00; BYMINUTE=15', 
              enabled			    => true,
							comments		    => 'Job de limpeza do LOG4PLSQL');
END;
/ 


DECLARE
  plogctx log4plsql.plog.log_ctx := plog.init;
  pdata   DATE := SYSDATE - 30;
BEGIN
  log4plsql.plog.purge(plogctx, pdata);
  COMMIT;
END;
/
