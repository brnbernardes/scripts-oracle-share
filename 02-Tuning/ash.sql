-- Bloqueada
SELECT * 
  FROM dba_hist_active_sess_history
 WHERE  session_id = '7579'
 AND session_serial# = '18924';

SELECT * 
  FROM dba_hist_active_sess_history
 WHERE  session_id = '140'
 AND session_serial# = '52249'; 

SELECT *
  FROM (SELECT (SELECT username FROM dba_users WHERE user_id = ash.user_id) username,
               session_id,
               session_serial#,
               event,
               sql_id,
               p1,
               p2,
               p3,
               p1text,
               p2text,
               p3text,
               ash.sql_opname,
               blocking_session,
               blocking_session_serial#,
               COUNT(1),
               MIN(sample_time),
               MAX(sample_time)
          FROM dba_hist_active_sess_history ash
         WHERE sample_time >= trunc(SYSDATE - 1)
           AND (session_id = 5883 AND session_serial# = 54865)
         GROUP BY user_id, session_id, session_serial#, event, sql_id, p1, p2, p3, p1text, p2text, p3text, sql_opname, blocking_session, blocking_session_serial#
         ORDER BY 9 DESC)
 WHERE rownum < 12;


-- Event
SELECT sql_id,
       event,
       COUNT(*),
       lpad(round(ratio_to_report(COUNT(*)) over() * 100) || '%', 10, ' ') percent
  FROM dba_hist_active_sess_history
 WHERE user_id = 1598
   AND sample_time >= trunc(SYSDATE - 1)
   AND session_id = '5883'
 GROUP BY sql_id, event
 ORDER BY percent DESC;


-- Object
SELECT *
  FROM (SELECT ash.sql_id,
               ash.current_obj#,
               obj.object_name,
               COUNT(*) AS wait_count
          FROM dba_hist_active_sess_history ash
          LEFT JOIN dba_objects obj
            ON obj.object_id = ash.current_obj#
         WHERE ash.sample_time BETWEEN TIMESTAMP '2022-10-20 00:00:00'
           AND TIMESTAMP '2022-10-21 00:00:00'
         GROUP BY ash.sql_id,
                  ash.top_level_sql_id,
                  ash.current_obj#,
                  obj.object_name
         ORDER BY 4 DESC)
 WHERE sql_id = '8q74zavb46tjx'
   AND rownum <= 10;


----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Bloqueadora
SELECT *
  FROM dba_hist_active_sess_history
 WHERE user_id = 1598
   AND sample_time >= trunc(SYSDATE - 1)
   AND session_id = '140';

SELECT *
  FROM dba_hist_active_sess_history
 WHERE sample_time >= trunc(SYSDATE - 1)
   AND session_id = '14187';


SELECT * FROM dba_hist_sqltext WHERE sql_id IN ('arhpsbhx971ww', '4pupfkj665ggx');


UPDATE sdv_registroremessa
   SET nossonumero    = :nossonumero,
       erro           = :erro,
       datapagamento  = :datapagamento,
       errodescricao  = :errodescricao,
       arquivoretorno = :arquivoretorno,
       pagamentosigef = :pagamentosigef
 WHERE codigo IN (:cd0, :cd1)
