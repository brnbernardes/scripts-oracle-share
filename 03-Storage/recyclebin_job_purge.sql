BEGIN
  dbms_scheduler.create_job('SYS.DBA_PURGE_RECYCLEBIN_J',
                            job_type => 'PLSQL_BLOCK',
                            job_action => 'BEGIN EXECUTE IMMEDIATE ''PURGE DBA_RECYCLEBIN''; dbms_stats.gather_table_stats(''SYS'', ''X$KTFBUE''); END;',
                            number_of_arguments => 0,
                            start_date => to_timestamp_tz('01-JAN-2024 12.00.00,000000000 AM AMERICA/SAO_PAULO', 'DD-MON-RRRR HH.MI.SSXFF AM TZR', 'NLS_DATE_LANGUAGE=english'),
                            repeat_interval => 'FREQ=WEEKLY;BYDAY=MON;BYHOUR=00;BYMINUTE=0;BYSECOND=0',
                            end_date => NULL,
                            job_class => '"DEFAULT_JOB_CLASS"',
                            enabled => FALSE, 
                            auto_drop => FALSE,
                            comments => 'Purge DBA_RECYCLEBIN.');
  dbms_scheduler.set_attribute('"DBA_PURGE_RECYCLEBIN_J"', 'NLS_ENV', 'NLS_LANGUAGE=''BRAZILIAN PORTUGUESE'' NLS_TERRITORY=''BRAZIL'' NLS_CURRENCY=''R$'' NLS_ISO_CURRENCY=''BRAZIL'' NLS_NUMERIC_CHARACTERS='',.'' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD/MM/RR'' NLS_DATE_LANGUAGE=''BRAZILIAN PORTUGUESE'' NLS_SORT=''WEST_EUROPEAN'' NLS_TIME_FORMAT=''HH24:MI:SSXFF'' NLS_TIMESTAMP_FORMAT=''DD/MM/RR HH24:MI:SSXFF'' NLS_TIME_TZ_FORMAT=''HH24:MI:SSXFF TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD/MM/RR HH24:MI:SSXFF TZR'' NLS_DUAL_CURRENCY=''Cr$'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
  dbms_scheduler.set_attribute('"DBA_PURGE_RECYCLEBIN_J"', 'logging_level', dbms_scheduler.logging_full);
  dbms_scheduler.enable('SYS.DBA_PURGE_RECYCLEBIN_J');
  COMMIT;
END;
/

-- Purge from Shared Pool: SQL_ID
BEGIN
  FOR sqlx IN (SELECT address, hash_value
                 FROM v$sql
                WHERE sql_id = '53y0c8gym6j0d')
  LOOP
    sys.dbms_shared_pool.purge('' || sqlx.address || ',' ||
                               sqlx.hash_value || '', 'C');
  END LOOP;
END;
/

-- Set interval job
BEGIN
  dbms_scheduler.set_attribute(name      => 'SYS.DBA_PURGE_RECYCLEBIN_J',
                               attribute => 'REPEAT_INTERVAL',
                               value     => 'FREQ=DAILY;BYHOUR=07;BYMINUTE=00;BYSECOND=0'
                               );
END;
/

-- Run Job
BEGIN
 dbms_scheduler.run_job(job_name => 'SYS.DBA_PURGE_RECYCLEBIN_J', 
                        use_current_session =>  FALSE 
                        );
END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN
dbms_scheduler.copy_job(old_job => 'SYS.DBA_PURGE_RECYCLEBIN_J', NEW_job => 'DBA_THEMA.DBA_PURGE_RECYCLEBIN_J');
END;
/

SELECT dbms_metadata.get_ddl('PROCOBJ', job_name, owner)
  FROM dba_scheduler_jobs
 WHERE job_name LIKE 'DBA_PURGE_RECYCLEBIN_J'
 AND owner = 'DBA_THEMA'
 ORDER BY owner, job_creator, job_name; 

BEGIN
dbms_scheduler.drop_job('DBA_THEMA.DBA_PURGE_RECYCLEBIN_J');
END;
/



