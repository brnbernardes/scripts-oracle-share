/*
 * TRACE VIA TRIGGER DE LOGON
 * Autor: Bruno Bernardes
*/

GRANT ALTER SESSION TO dba_thema;
GRANT ALTER SESSION TO nfse;

--

DROP TRIGGER dba_thema.trace_logon_nfse;
DROP TRIGGER dba_thema.trace_logoff_nfse;

--

------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER dba_thema.trace_logon
  AFTER logon ON ACESSODIRETO.schema WHEN (upper(sys_context('USERENV', 'CLIENT_IDENTIFIER')) = 'ADRIANO.SANTOS') 
BEGIN
  EXECUTE IMMEDIATE 'alter session set tracefile_identifier =''nfse''';
  EXECUTE IMMEDIATE 'alter session set sql_trace=true';
  EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever,level 12''';
  EXECUTE IMMEDIATE 'alter session set statistics_level=all';
  EXECUTE IMMEDIATE 'alter session set max_dump_file_size = unlimited';
EXCEPTION
  WHEN OTHERS THEN
   sys.dbms_system.ksdwrt(2, 'TRIGGER TRACE LOGON ERRO:'); 
   sys.dbms_system.ksdwrt(2, SQLERRM); 
END;
/

CREATE OR REPLACE TRIGGER dba_thema.trace_logoff
  BEFORE logoff ON ACESSODIRETO.schema WHEN (upper(sys_context('USERENV', 'CLIENT_IDENTIFIER')) = 'ADRIANO.SANTOS') 
BEGIN
  EXECUTE IMMEDIATE 'alter session set sql_trace = false';
  EXECUTE IMMEDIATE 'alter session set statistics_level=typical';
EXCEPTION
  WHEN OTHERS THEN
   sys.dbms_system.ksdwrt(2, 'TRIGGER TRACE LOGOFF ERRO:'); 
   sys.dbms_system.ksdwrt(2, SQLERRM); 
END;
/


------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE TRIGGER dba_thema.trace_logon_t
  AFTER logon ON ACESSO_ERP.schema
BEGIN
  EXECUTE IMMEDIATE 'alter session set tracefile_identifier =''ACESSO_ERP''';
  EXECUTE IMMEDIATE 'alter session set sql_trace=true';
  EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever,level 12''';
  EXECUTE IMMEDIATE 'alter session set statistics_level=all';
  EXECUTE IMMEDIATE 'alter session set max_dump_file_size = unlimited';
EXCEPTION
  WHEN OTHERS THEN
   sys.dbms_system.ksdwrt(2, 'TRIGGER-TRACE LOGON ERRO:'); 
   sys.dbms_system.ksdwrt(2, SQLERRM); 
END;
/

CREATE OR REPLACE TRIGGER dba_thema.trace_logoff_t
  BEFORE logoff ON ACESSO_ERP.schema
BEGIN
  EXECUTE IMMEDIATE 'alter session set sql_trace = false';
  EXECUTE IMMEDIATE 'alter session set statistics_level=typical';
EXCEPTION
  WHEN OTHERS THEN
   sys.dbms_system.ksdwrt(2, 'TRIGGER-TRACE LOGOFF ERRO:'); 
   sys.dbms_system.ksdwrt(2, SQLERRM); 
END;
/




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create or replace trigger tr_turnon_traceperuser
  after logon on database
    WHEN ( USER IN ('FABIO'))
declare
 sqlstr_id varchar2(200);
 sid_number integer;
begin
--------------------------------------------------------------------------------
-- TRIGGER: tr_turnon_traceperuser
--------------------------------------------------------------------------------
-- Data: 26/08/2018
-- Nome: Fábio Prado (www.fabioprado.net)
-- Descrição: Trigger para habilitar sql trace estendido nas sessoes de um ou mais usuarios do bd. Os traces sao gerados com nome de arquivo seguindo o padrao: sqltrace_usuario_sid.trc.
--------------------------------------------------------------------------------
--      HISTÓRICO ALTERAÇÕES
--------------------------------------------------------------------------------
    -- recupera sid da sessao atual:
    select sys_context('userenv', 'sid') into sid_number from dual;

    -- configura/executa comando para customizar nome do sql trace contendo nome do usuario + sid:
  sqlstr_id := 'alter session set tracefile_identifier = sqltrace_' || user || '_' || to_char(sid_number);  
  execute immediate sqlstr_id;

  -- habilita sql trace na sessao do usuario:
  dbms_monitor.session_trace_enable(waits=>true, binds=>true);
end;




