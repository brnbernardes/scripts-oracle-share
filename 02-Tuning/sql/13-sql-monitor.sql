select sid,
         session_serial#,
         sql_id,
         sql_exec_id,
         to_char(sql_exec_start,'DD-Mon-YY HH24:MI:SS') sql_exec_start,
         sql_plan_hash_value plan_hash_value,
         elapsed_time/1000000 etime,
         buffer_gets,
         disk_reads
     from v$sql_monitor
    where sql_id = '4k0y5329sn48q';

select DBMS_SQLTUNE.REPORT_SQL_MONITOR(session_id=> 1290, session_serial=> 2327, sql_id=> '4k0y5329sn48q', sql_exec_id=> '33554432', report_level=>'ALL') as report from dual;