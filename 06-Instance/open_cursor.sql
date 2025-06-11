show parameter cursor

-- Verificar configuração atual de cursores
col MAX_OPEN_CUR format a20
select max(a.value) as highest_open_cur, p.value as max_open_cur
from gv$sesstat a, gv$statname b, gv$parameter p
where a.statistic# = b.statistic#
and b.name = 'opened cursors current'
and p.name = 'open_cursors'
group by p.value;

-- Cursor aberto por usuário
select s.username, max(a.value)
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#
and s.sid (+)= a.sid
and b.name = 'opened cursors current'
group by s.username;

-- Cursor aberto por session
select s.sid, s.username, client_identifier, max(a.value)
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic#
and s.sid (+)= a.sid
and b.name = 'opened cursors current'
group by s.sid, s.username, client_identifier
order by 4;

-- Cursor aberto do ACESSODIRETO (client_identifier is null)
SET COLSEP '|'
COL machine FOR a43
COL program FOR a20
WITH opened_cursors AS 
(SELECT s.status,
       s.sid,
       s.username,
       s.machine,
       s.program,
       last_call_et last_call_et_sec,
       (SYSDATE - last_call_et / 86400) last_call_date,
       a.value open_cursors_per_session
  FROM v$sesstat a, v$statname b, v$session s
 WHERE a.statistic# = b.statistic#
   AND s.sid(+) = a.sid
   AND b.name = 'opened cursors current'
   AND s.username LIKE 'ACESSODIRETO'
   AND s.client_identifier IS NULL)
SELECT s.sid,
       open_cursors_per_session,
       s.machine,
       s.program,
       oc.sql_id,
       oc.sql_text,
       COUNT(1) oper_cursors_per_sql_id
  FROM opened_cursors s
 INNER JOIN v$open_cursor oc
    ON oc.sid = s.sid
   AND oc.user_name = s.username
   WHERE open_cursors_per_session > 1000 
 GROUP BY s.sid, s.machine, s.program, oc.sql_id, oc.sql_text, open_cursors_per_session
ORDER BY 1;