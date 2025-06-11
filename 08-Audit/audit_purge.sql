---------------------------------------------------------------------------------------------------------------------------------------
-- Parameters: Tablespace Configuration
---------------------------------------
SELECT parameter_name,
       parameter_value,
       audit_trail
  FROM dba_audit_mgmt_config_params
 WHERE parameter_name = 'DB AUDIT TABLESPACE';

---------------------------------------------------------------------------------------------------------------------------------------
-- Objects Size
---------------
SELECT owner,
       segment_name,
       SUM(bytes) / 1024 / 1024 / 1024,
       tablespace_name
  FROM dba_segments
 WHERE segment_name IN ('AUD$', 'FGA_LOG$')
 GROUP BY owner,
          segment_name,
          tablespace_name;

---------------------------------------------------------------------------------------------------------------------------------------
-- Create Tablespace
---------------------
CREATE BIGFILE TABLESPACE "AUDIT_ORACLE" 
  DATAFILE SIZE 1G AUTOEXTEND ON NEXT 128M MAXSIZE 64G --> Deve ter SIZE como tamanho total para receber os blocos da auditoria (não realiza o extend do datafile)
  LOGGING ONLINE PERMANENT BLOCKSIZE 8192
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  ENCRYPTION USING 'AES128' ENCRYPT DEFAULT 
 NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO;

---------------------------------------------------------------------------------------------------------------------------------------
-- STANDARD AUDIT TRAIL
-----------------------

SELECT COUNT(1) FROM sys.aud$;
SELECT MIN(TIMESTAMP), MAX(TIMESTAMP) FROM dba_audit_object;

--  Clear:
BEGIN
  dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                             last_archive_time => SYSTIMESTAMP - INTERVAL '30' DAY);

  dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                    use_last_arch_timestamp => TRUE);
END;
/

-- Set New Tablespace (move):
BEGIN
  dbms_audit_mgmt.set_audit_trail_location(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                           audit_trail_location_value => 'AUDIT_ORACLE');
 COMMIT;                                             
END;
/

-- Job Purge 
BEGIN
  dbms_scheduler.create_job('DBA_THEMA.PURGE_AUDIT_ORACLE_STD_J',
                            job_type => 'PLSQL_BLOCK',
                            job_action => 'BEGIN
  dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                             last_archive_time => SYSTIMESTAMP - INTERVAL ''30'' DAY);
  dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                    use_last_arch_timestamp => TRUE);
COMMIT;
END;',                      number_of_arguments => 0,
                            start_date => to_timestamp_tz('05-05-2025 04.00.00,000000000 AM AMERICA/SAO_PAULO',
                                                           'DD-MM-RRRR HH.MI.SSXFF AM TZR',
                                                           'NLS_DATE_LANGUAGE=english'),
                            repeat_interval => 'freq=daily; interval=1; byhour=04',
                            end_date => NULL,
                            job_class => '"DEFAULT_JOB_CLASS"',
                            enabled => FALSE, auto_drop => FALSE,
                            comments => 'Expurga Auditoria Oracle Standard com período de retenção de 30 dias.');
  sys.dbms_scheduler.set_attribute('"PURGE_AUDIT_ORACLE_STD_J"', 'NLS_ENV',
                                   'NLS_LANGUAGE=''BRAZILIAN PORTUGUESE'' NLS_TERRITORY=''BRAZIL'' NLS_CURRENCY=''R$'' NLS_ISO_CURRENCY=''BRAZIL'' NLS_NUMERIC_CHARACTERS='',.'' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD/MM/RR'' NLS_DATE_LANGUAGE=''BRAZILIAN PORTUGUESE'' NLS_SORT=''WEST_EUROPEAN'' NLS_TIME_FORMAT=''HH24:MI:SSXFF'' NLS_TIMESTAMP_FORMAT=''DD/MM/RR HH24:MI:SSXFF'' NLS_TIME_TZ_FORMAT=''HH24:MI:SSXFF TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD/MM/RR HH24:MI:SSXFF TZR'' NLS_DUAL_CURRENCY=''Cr$'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
  dbms_scheduler.set_attribute('"PURGE_AUDIT_ORACLE_STD_J"',
                               'logging_level', dbms_scheduler.logging_full);
  dbms_scheduler.enable('"PURGE_AUDIT_ORACLE_STD_J"');
  COMMIT;
END;
/


---------------------------------------------------------------------------------------------------------------------------------------
--  UNIFIED AUDIT TRAIL
-----------------------

SELECT COUNT(1) FROM unified_audit_trail;

-- Clear
BEGIN
  dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
                                             last_archive_time => SYSTIMESTAMP - INTERVAL '30' DAY);

  dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
                                    use_last_arch_timestamp => TRUE);
END;
/

-- Set New Tablespace (move):
BEGIN
  dbms_audit_mgmt.set_audit_trail_location(audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
                                           audit_trail_location_value => 'AUDIT_ORACLE');
 COMMIT;                                             
END;
/

---------------------------------------------------------------------------------------------------------------------------------------
-- STANDARD FGA AUDIT TRAIL
---------------------------

SELECT COUNT(1) FROM sys.fga_log$;


--  Clear:
BEGIN
  dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                             last_archive_time => SYSTIMESTAMP - INTERVAL '30' DAY);

  dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.audit_trail_aud_std,
                                    use_last_arch_timestamp => TRUE);
END;
/

-- Set New Tablespace (move):
BEGIN
  dbms_audit_mgmt.set_audit_trail_location(audit_trail_type => dbms_audit_mgmt.audit_trail_fga_std,
                                           audit_trail_location_value => 'AUDIT_ORACLE');
 COMMIT;                                             
END;
/