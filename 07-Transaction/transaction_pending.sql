-----------------------------
--Transection Pending
--
SELECT sql.rows_processed, p.spid,
       s.inst_id, s.sid, s.serial#, s.sql_id, S.prev_sql_id, sql.sql_text, sql.sql_fulltext, s.username,
       s.program, client_identifier, osuser, wait_class, type,
       state, event, logon_time, 'alter system kill session ''' || s.sid || ',' || s.serial# || ''';' kill, s.paddr, s.taddr
  FROM gv$session s
  LEFT JOIN gv$process p
    ON p.addr = s.paddr
   AND p.inst_id = s.inst_id
  LEFT JOIN gv$sqlarea sql
    ON nvl(s.sql_id, s.prev_sql_id) = sql.sql_id
  INNER JOIN v$transaction t
ON  s.saddr = t.ses_addr;
