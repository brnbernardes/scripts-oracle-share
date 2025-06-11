-- Get Schema Stats
BEGIN 
 DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'ERP', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE);
END; 
/


BEGIN 
 DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'ERP', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt = 'for all columns size auto', cascade => TRUE);
END; 
/

-- Create Job ERP
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"DBA_THEMA"."DBA_STATS_ERP"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'BEGIN DBMS_STATS.GATHER_SCHEMA_STATS(ownname => ''ERP'', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, options=> ''GATHER'', granularity => ''AUTO'', method_opt => ''FOR ALL COLUMNS SIZE AUTO'', cascade => TRUE); END;',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2022-01-01 00:00:00 AMERICA/SAO_PAULO','YYYY-MM-DD HH24:MI:SS TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYDAY=SAT;BYHOUR=12;BYMINUTE=0;BYSECOND=0',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Coleta de estatísticas do schema ERP.');

    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"DBA_THEMA"."DBA_STATS_ERP"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.logging_full);
      
    DBMS_SCHEDULER.enable(
             name => '"DBA_THEMA"."DBA_STATS_ERP"');
END;
/


-- Running Job
BEGIN
    DBMS_SCHEDULER.RUN_JOB(job_name => '"DBA_THEMA"."DBA_STATS_ERP"', USE_CURRENT_SESSION => FALSE);
END;
/

-- Define novos atributos, jobs para PDBs do Cloud-Thema
BEGIN
  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'job_action',
                              VALUE => 'BEGIN DBMS_STATS.GATHER_SCHEMA_STATS(ownname => ''ERP'', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, options=> ''GATHER'', granularity => ''AUTO'', method_opt => ''FOR ALL COLUMNS SIZE AUTO'', cascade => TRUE, degree => 2); END;');
  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'comments',
                              VALUE => 'Coleta de estatísticas do schema ERP.');    

  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'logging_level',
                              VALUE => dbms_scheduler.logging_full );
                                                            
END;
/

BEGIN
  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'job_action',
                              VALUE => 'BEGIN DBMS_STATS.GATHER_SCHEMA_STATS(ownname => ''ERP'', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, options=> ''GATHER'', granularity => ''AUTO'', method_opt => ''FOR ALL COLUMNS SIZE AUTO'', cascade => TRUE); END;');
  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'comments',
                              VALUE => 'Coleta de estatísticas do schema ERP.');    

  dbms_scheduler.set_attribute(NAME => 'DBA_THEMA.DBA_STATS_ERP',
                              attribute => 'logging_level',
                              VALUE => dbms_scheduler.logging_full );
                                                            
END;
/

-- Query
col job_creator for a11
col owner for a11
col job_name for a30
col repeat_interval for a40
col last_run_duration for a30
SELECT j.job_creator,
          j.owner,
          j.job_name,
          j.repeat_interval,
          j.enabled,
          to_date(to_char(j.last_start_date, 'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') last_start_date,
          to_date(to_char(j.next_run_date, 'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') next_run_date,
          j.failure_count,
          last_run_duration
      FROM dba_scheduler_jobs j
    WHERE  job_name = 'DBA_STATS_ERP';


SELECT j.job_creator,
          j.owner,
          j.job_name,
          j.job_action,
          j.repeat_interval,
          j.enabled, 
          j.state, 
          to_date(to_char(j.last_start_date, 'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') last_start_date,
          to_date(to_char(j.next_run_date, 'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') next_run_date,
          j.failure_count,
          last_run_duration,
          logging_level,
          auto_drop,
          instance_id,
          comments
      FROM dba_scheduler_jobs j
    WHERE  upper(job_action) LIKE '%DBMS_STATS%';


-- Create Job ADMRH
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"DBA_THEMA"."DBA_STATS_ADMRH"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'BEGIN
  FOR c IN (SELECT owner, COUNT(1) qtd
              FROM dba_objects
             WHERE owner LIKE ''ADMRH%''
               AND object_type LIKE ''TABLE''
             GROUP BY owner
             ORDER BY 2 DESC) LOOP
    dbms_stats.gather_schema_stats(ownname => c.owner,
                                   estimate_percent => dbms_stats.auto_sample_size,
                                   options => ''gather'',
                                   granularity => ''auto'',
                                   method_opt => ''FOR ALL COLUMNS SIZE AUTO'',
                                   cascade => TRUE);
  END LOOP;
END;', 
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2024-02-26 00:00:00 AMERICA/SAO_PAULO','YYYY-MM-DD HH24:MI:SS TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYDAY=SUN;BYHOUR=12;BYMINUTE=0;BYSECOND=0',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Coleta de estatísticas dos schemas da ADMRH.');

    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"DBA_THEMA"."DBA_STATS_ADMRH"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.logging_full);
      
    DBMS_SCHEDULER.enable(
             name => '"DBA_THEMA"."DBA_STATS_ADMRH"');
END;
/