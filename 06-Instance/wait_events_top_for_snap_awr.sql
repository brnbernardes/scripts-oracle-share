--> https://www.oracle.com/br/technical-resources/articles/database-performance/oracle-wait-interface-owi.html

SELECT a.snap_id,
       to_char(a.begin_interval_time, 'dd/mm/yyyy hh24:mi:ss') begin_interval_time,
       to_char(a.end_interval_time, 'dd/mm/yyyy hh24:mi:ss') end_interval_time
  FROM dba_hist_snapshot a
 ORDER BY 1 DESC;

SELECT snap_id,
       begin_time,
       end_time,
       (SELECT i.instance_name
          FROM gv$instance i
         WHERE i.instance_number = a.instance_number) AS "INSTANCE",
       event_name,
       total_waits AS "WAITS",
       event_time_waited AS "TIME(s)",
       avg_wait AS "AVG_WAIT(ms)",
       pct AS "%PCT",
       wait_class
  FROM (SELECT to_char(s.begin_interval_time, 'DD-MM-YYYY HH24:MI') AS begin_time,
               to_char(s.end_interval_time, 'DD-MM-YYYY HH24:MI') AS end_time,
               m.*
          FROM (SELECT ee.instance_number,
                       ee.snap_id,
                       ee.event_name,
                       round(ee.event_time_waited / 1000000) event_time_waited,
                       ee.total_waits,
                       round((ee.event_time_waited * 100) /
                             et.total_time_waited, 1) pct,
                       round((ee.event_time_waited / ee.total_waits) / 1000) avg_wait,
                       ee.wait_class
                  FROM (SELECT ee1.instance_number,
                               ee1.snap_id,
                               ee1.event_name,
                               ee1.time_waited_micro - ee2.time_waited_micro event_time_waited,
                               ee1.total_waits - ee2.total_waits total_waits,
                               ee1.wait_class
                          FROM dba_hist_system_event ee1
                          JOIN dba_hist_system_event ee2
                            ON ee1.snap_id = ee2.snap_id + 1
                           AND ee1.instance_number = ee2.instance_number
                           AND ee1.event_id = ee2.event_id
                           AND ee1.wait_class_id <> 40
                           AND ee1.time_waited_micro - ee2.time_waited_micro > 0
                        UNION
                        SELECT st1.instance_number,
                               st1.snap_id,
                               st1.stat_name event_name,
                               st1.value - st2.value event_time_waited,
                               NULL total_waits,
                               NULL wait_class
                          FROM dba_hist_sys_time_model st1
                          JOIN dba_hist_sys_time_model st2
                            ON st1.instance_number = st2.instance_number
                           AND st1.snap_id = st2.snap_id + 1
                           AND st1.stat_id = st2.stat_id
                           AND st1.stat_name = 'DB CPU'
                           AND st1.value - st2.value > 0) ee
                  JOIN (SELECT et1.instance_number,
                              et1.snap_id,
                              et1.value - et2.value total_time_waited,
                              NULL wait_class
                         FROM dba_hist_sys_time_model et1
                         JOIN dba_hist_sys_time_model et2
                           ON et1.snap_id = et2.snap_id + 1
                          AND et1.instance_number = et2.instance_number
                          AND et1.stat_id = et2.stat_id
                          AND et1.stat_name = 'DB time'
                          AND et1.value - et2.value > 0) et
                    ON ee.instance_number = et.instance_number
                   AND ee.snap_id = et.snap_id) m
          JOIN dba_hist_snapshot s
            ON m.snap_id = s.snap_id
         WHERE m.instance_number = 1
           AND m.snap_id = 21138 --Aqui você coloca o SNAP_ID capturado na query acima
         ORDER BY pct DESC) a
 WHERE rownum <= 5 --Quantidade de linhas retornadas, especifique 10 e você tera um TOP 10
/
