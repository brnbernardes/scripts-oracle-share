----------------------------------------------------------------------------------------
--SO TIMEZONE 
cat /etc/os-release
zdump v Brazil/East | grep 2023


----------------------------------------------------------------------------------------
--DB TIMEZONE
SELECT SYSDATE,
       systimestamp,
       current_date,
       sessiontimezone,
       to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS "SYSDATE",
       systimestamp at TIME ZONE 'America/Sao_Paulo' AS "SYSTIMESTAMP_AMERICA_SAOPAULO",
       systimestamp at TIME ZONE 'Brazil/East' AS "SYSTIMESTAMP_BRAZIL_EAST",
       to_char(systimestamp at TIME ZONE 'Brazil/East','DD/MM/YYYY HH24:MI:SS') AS tocharsysbrazil,
       to_char(systimestamp at TIME ZONE 'America/Sao_Paulo','DD/MM/YYYY HH24:MI:SS') AS tocharsysamerica
  FROM dual;

SELECT * FROM v$timezone_file;


----------------------------------------------------------------------------------------
--SCHEDULER_JOBS

-- Verificação do timestamp default
SELECT dbms_scheduler.stime FROM dual;

-- Definição do timestamp default
BEGIN
  -- DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('default_timezone','AMERICA/SAO_PAULO');
   DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('default_timezone','-03:00');   
END;
/

-- Verificar se fuso horário atual condiz com next_run_date
SELECT job_creator,
       owner || '.' || job_name job_name,
       enabled,
       state,
       start_date,
       to_date(to_char(last_start_date, 'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') last_start_date,
       to_date(to_char(next_run_date, 'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss') next_run_date
  FROM dba_scheduler_jobs j  
 WHERE schedule_name IS NULL
 AND  to_char(start_date,'TZR') LIKE '%AMERICA%'
ORDER BY next_run_date;

-- Alterar timestamp de AMERICAN/SAO_PAULO para -03:00
BEGIN
  FOR c IN (SELECT j.owner || '.' || j.job_name job_name,
                   to_timestamp_tz(to_char(start_date,'DD/MM/YYYY HH24:MI:SS') ||' -03:00', 'DD/MM/YYYY HH24:MI:SS TZR') new_timestamp
              FROM dba_scheduler_jobs j
             WHERE to_char(start_date, 'TZR') LIKE '%AMERICA%'
             AND schedule_name IS NULL) LOOP
    dbms_scheduler.set_attribute(NAME => c.job_name,
                                 attribute => 'start_date',
                                 VALUE => c.new_timestamp);
  END LOOP;
END;
/


