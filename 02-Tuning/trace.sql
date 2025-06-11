------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace: find session
SELECT s.sid,
       s.serial#,
       s.client_identifier,
       '-->'||p.tracefile || CHR(10)||
       'BEGIN' || CHR(10) || ' dbms_monitor.session_trace_enable(' || s.sid || ',' || s.serial# || ', waits => true, binds => true );'|| CHR(10) || 'END;' || CHR(10) ||'/' || CHR(10) ||
       'BEGIN' || CHR(10) || ' dbms_monitor.session_trace_disable(' || s.sid || ',' || s.serial# || ');'|| CHR(10) || 'END;' || CHR(10) ||'/' "TRACE"
  FROM gv$session s
 INNER JOIN gv$process p
    ON p.addr = s.paddr
   AND p.inst_id = s.inst_id
 WHERE s.sid <> sys_context('USERENV', 'SID')
   AND s.username = 'ACESSODIRETO'
   AND s.status = 'ACTIVE'
   AND s.client_identifier IS NOT NULL
 ORDER BY last_call_et;

------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace via sessao target
BEGIN
 sys.dbms_monitor.session_trace_enable (&sid, &serial, waits => true, binds => true );
END;
/

BEGIN
 sys.dbms_monitor.session_trace_disable (&sid, &serial);
END;
/


SELECT sys_context('USERENV', 'SID') "SID", 
       sys_context('USERENV', 'SESSION_USER') "USER",
       sys_context('USERENV', 'CURRENT_SCHEMA') "CURRENT_SCHEMA"
 FROM dual;


------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace from CURSOR CACHE
BEGIN
  dbms_sqldiag.dump_trace(p_sql_id => '8kxjugajjx4xp', p_child_number => 0,
                          p_component => 'Compiler', -- or Optimizer
                          p_file_id => 'SQL_8kxjugajjx4xp');
END;
/

------------------------------------------------------------------------------------------------------------------------------------------------
-- TKPROF File:
/*
 - call: Nome da fase de execução da instrução SQL;
 - count: Quantidade de vezes em que a instrução passou por uma determinada fase;
 - cpu: Tempo total de cpu dedicado à instrução SQL. 
 - elapsed disk: Tempo total de execução dedicado à instrução SQL. Inclui tempo de execução e tempo e espera;
 - disk: Quantidade total de blocos lidos/escritos em disco;
 - query: Quantidade total de blocos lidos em memória (leitura consistente);
 - current: Quantidade total de blocos lidos em memória (dados atuais, lidos normalmente em UPDATEs);
 - rows: Quantidade total de linhas processadas.
 -
 - cr (consistent reads): Qtde. de blocos lidos em memória de forma consistente;
 - pr (physical reads): Qtde. de blocos lidos em disco;
 - pw (physical writes): Qtde. de blocos escritos em disco;
 - time (elapsed time): Tempo total gasto em microsegundos pela operação. (1.000.000 micro = 1 segundo)
 - cost (optimizer cost): Custo da operação.
 - size (estimated size): Tamanho estimado em bytes dos dados processados.
 - card (estimated cardinality): Qtde. estimada de linhas processadas.
*/
-- Gerar Tkprof
tkprof <nome_arquivo.trc> <nome_arquivo_destino.txt> explain=<user/password@tns> waits=yes sys=no sort=exeela,fchela,execpu
tkprof exe.trc exe.tk waits=yes sys=no explain='"/ as sysdba"'

-- Sort
sort=exeela,fchela,execpu
sort=prsela,exeela,fchela
sort=prscpu,execpu,fchela

------------------------------------------------------------------------------------------------------------------------------------------------
--Sqlplus autotrace 
set line 200 pages 999
set timing on
set autotrace traceonly
set echo on
carregar contexto...
query...

------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace da própria sessão
alter session set tracefile_identifier='TESTE';
alter session set sql_trace=true;
alter session set sql_trace=false;
-- Elevar estatísticas a nível de sessão
alter session set timed_statistics = true; 
alter session set statistics_level = all; --> or hint - /*+ gather_plan_statistics */ 
------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace Execution
alter session set max_dump_file_size = unlimited; 
alter session set timed_statistics = true; 
alter session set statistics_level=all; 
alter session set events '10046 trace name context forever, level 12'; 
--query
select 'close the cursor' from dual; 
alter session set events '10046 trace name context off'; 

------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace Parse
alter session set max_dump_file_size = unlimited; 
alter session set timed_statistics = true; 
alter session set statistics_level=all; 
alter session set events '10053 trace name context forever, level 12'; 
--query
select 'close the cursor' from dual; 
alter session set events '10053 trace name context off'; 


------------------------------------------------------------------------------------------------------------------------------------------------
-- Trace via client_identifier
BEGIN
 dbms_monitor.client_id_stat_enable('spprev');
END;
/

------------------------------------------------------------------------------------------------------------------------------------------------
-- Grant user ACESSODIRETO explain plan
grant create table to acessodireto;
grant bas$_usuario_select_tab_role to acessodireto;
select default_tablespace from dba_users where username like 'ACESSODIRETO';
alter user acessodireto quota unlimited on geral; 
-- Revoke user ACESSODIRETO explain plan
alter user acessodireto quota 0 on geral; 
revoke bas$_usuario_select_tab_role from acessodireto;
revoke create table from acessodireto;

-------------------------------------------------------------------------------------------------------------------------
--If you are licensed for it (Diag + Tuning), you can also use ... for queries under the real time sql monitoring umbrella
V$SQL_MONITOR.BIND_XML 
