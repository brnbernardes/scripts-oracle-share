--SESSOES MARCADAS PARA ELIMINAÇÃO 
SELECT s.inst_id, s.sid, s.SERIAL#, s.STATUS, s.USERNAME, s.MACHINE, s.client_identifier
  FROM gv$session s
 WHERE s.status = 'KILLED'; 

--VERIFICA SESS�ES QUE ESTÃO REALIZNADO ROLLBACK
select t.INST_ID,
       s.sid,
       s.program,
       t.status as transaction_status,
       s.status as session_status,
       s.lockwait,
       s.pq_status,
       t.used_ublk as undo_blocks_used,
       decode(bitand(t.flag, 128), 0, 'NO', 'YES') rolling_back
  from gv$session s, gv$transaction t
 where s.taddr = t.addr
   and s.inst_id = t.inst_id
   and s.STATUS = 'KILLED'
 order by t.inst_id; 

--STATUS KILLED: VALIDA REFRENCIA AO PROCESSO DO SO 
SELECT s.username, s.osuser, s.machine, s.sid, s.serial#, p.spid
    FROM gv$session s, gv$process p
   WHERE s.inst_id = p.inst_id
   AND s.paddr = p.addr
   AND s.username IS NOT NULL
   AND s.STATUS = 'KILLED';

--SE "SQL*Net message from client" a sessão recebeu o kill e tentou comunicar isso ao cliente, como não conseguiu e ficou no limbo
SELECT sw.INST_ID, SW.SID, SW.SEQ#, SW.EVENT, SW.STATE, sw.WAIT_TIME
   FROM gv$session_wait sw
   WHERE sw.sid IN (SELECT sid FROM gv$session s WHERE s.status = 'KILLED' AND s.inst_id = sw.INST_ID)
   ORDER BY sw.inst_id;   

--Após a receber o kill e tentar comunicar o cliente o Oracle modificou o “paddr” da sessão. 
--Assim, a ligação entre a gv$session e a gv$process foi “interrompida”.
--PROCESSOS SEM SESSÕES
SELECT p.INST_ID, p.pid, p.serial#, p.spid, p.program
FROM gv$process p
  WHERE p.spid is not null
  AND NOT EXISTS (SELECT 1 FROM gv$session s WHERE s.inst_id = p.inst_id and s.paddr = p.addr)
  AND p.pname is null
  ORDER BY p.inst_id;   
