
-- criar tablesapce
CREATE TABLESPACE "PERFSTAT" DATAFILE '/u01/app/oracle/oradata/pmcs/perfstat01.dbf' SIZE 1G AUTOEXTEND ON NEXT 256M MAXSIZE 16g
LOGGING ONLINE PERMANENT BLOCKSIZE 8192
EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT 
NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO;

-- criar usuario 
@?/rdbms/admin/spcreate.sql

-- alteracao do nível de coleta
exec statspack.snap(i_snap_level => 6, i_modify_parameter => 'true');

-- privilégio de criacao de jobs
grant create job to perfstat;

--connectar como PERFSTAT, para criar jobs:
BEGIN
  --dbms_scheduler.drop_job(job_name => 'PERFSTAT.STATSPACK_SNAPSHOT');
  dbms_scheduler.create_job(job_name => 'PERFSTAT.STATSPACK_SNAPSHOT',
                            job_type => 'STORED_PROCEDURE',
                            job_action => 'STATSPACK.SNAP',
                            number_of_arguments => 0,
                            start_date => to_timestamp_tz('2024-01-24 00:00:00 AMERICA/SAO_PAULO','YYYY-MM-DD HH24:MI:SS TZR'),
                            repeat_interval => 'freq=hourly; byminute=00,30',
                            end_date => NULL, enabled => FALSE,
                            auto_drop => FALSE,
                            comments => 'Statspack collection');

  dbms_scheduler.set_attribute(NAME => 'PERFSTAT.STATSPACK_SNAPSHOT', attribute => 'logging_level', VALUE => dbms_scheduler.logging_failed_runs);
  dbms_scheduler.enable(NAME => 'PERFSTAT.STATSPACK_SNAPSHOT');
END;
/

BEGIN   
    --dbms_scheduler.drop_job(job_name => 'PERFSTAT.STATSPACK_PURGE_SNAPSHOTS');
    dbms_scheduler.create_job (
            job_name => 'PERFSTAT.STATSPACK_PURGE_SNAPSHOTS',
            job_type => 'PLSQL_BLOCK',
            job_action => 'STATSPACK.PURGE(I_NUM_DAYS => 3);',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2024-01-24 00:00:00 AMERICA/SAO_PAULO','YYYY-MM-DD HH24:MI:SS TZR'),          
            repeat_interval => 'FREQ=DAILY; BYHOUR=04; BYMINUTE=30',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Statspack snapshots purge');

    dbms_scheduler.set_attribute(name => 'PERFSTAT.STATSPACK_PURGE_SNAPSHOTS', attribute => 'logging_level', value => DBMS_SCHEDULER.logging_failed_runs);
    dbms_scheduler.enable(name => 'PERFSTAT.STATSPACK_PURGE_SNAPSHOTS');
END;
/


-- verificar jobs criados
SELECT owner,
       job_name,
       program_name,
       to_char(start_date, 'YYYY/MM/DD HH24:MI') "FIRST",
       to_char(next_run_date, 'YYYY/MM/DD HH24:MI') "NEXT",
       to_char(last_start_date, 'YYYY/MM/DD HH24:MI') "LAST"
  FROM dba_scheduler_jobs
 WHERE owner = 'PERFSTAT';


-- verificar armazenamento utilizado
SELECT round(SUM(bytes) / 1024 / 1024, 1) "PERFSTAT MB"
  FROM dba_segments
 WHERE owner = 'PERFSTAT';

--Report
@?/rdbms/admin/spreport.sql

--Execution Plan
@?/rdbms/admin/sprepsql.sql


