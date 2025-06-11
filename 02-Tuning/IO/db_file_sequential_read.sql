/*
A dica deste script está nas colunas SINGLEBLKRDTIM e SINGLEBLKRDS:

SINGLEBLKRDTIM: Tempo cumulativo de leitura de single blocks lidos em determinado tempo (dado em centésimo de segundos) 
SINGLEBLKRDS: número de blocos lidos.

Extair a maior média e trabalhar juntamente com a equipe de SO/Storage para detectar possíveis gargalos.
Assim conseguiremos mensurar onde está a lentidão do nosso ambiente.
*/

SELECT a.file#,
       b.file_name,
       a.singleblkrds,
       a.singleblkrdtim,
       a.singleblkrdtim / a.singleblkrds average_wait
  FROM v$filestat a, dba_data_files b
 WHERE a.file# = b.file_id
   AND a.singleblkrds > 0
 ORDER BY average_wait DESC;


SELECT Substr(d.name,1,50) "File Name",
       f.phyblkrd "Blocks Read",
       f.phyblkwrt "Blocks Writen",
       f.phyblkrd + f.phyblkwrt "Total I/O"
FROM   v$filestat f,
       v$datafile d
WHERE  d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SELECT a.inst_id,
       a.sid,
       c.pid,
       c.spid,
       a.username,
       b.event,
       b.wait_time,
       b.seconds_in_wait,
       b.p1,
       b.p2,
       b.p3
  FROM gv$session a, gv$session_wait b, gv$process c
 WHERE a.sid = b.sid
   AND a.paddr = c.addr
   AND a.inst_id = c.inst_id
   AND b.event = 'db file sequential read';