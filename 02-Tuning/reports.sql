-------------------------------------------------------------------------------------
-- REPORTS
-------------------------------------------------------------------------------------

-- Auto Tuning Task @ cdb
set serveroutput on 
DECLARE
  my_rept CLOB;
  PROCEDURE print_clob(p_clob IN CLOB) IS
    v_offset     NUMBER DEFAULT 1;
    v_chunk_size NUMBER := 10000;
  BEGIN
    LOOP
      EXIT WHEN v_offset > dbms_lob.getlength(p_clob);
      dbms_output.put_line(dbms_lob.substr(p_clob, v_chunk_size, v_offset));
      v_offset := v_offset + v_chunk_size;
    END LOOP;
  END print_clob;
BEGIN
  dbms_output.enable(NULL);
  my_rept := dbms_sqltune.report_auto_tuning_task(begin_exec => NULL,
                                                  end_exec => NULL,
                                                  TYPE => 'TEXT',
                                                  LEVEL => 'TYPICAL',
                                                  section => 'ALL',
                                                  object_id => NULL,
                                                  result_limit => NULL);
  print_clob(my_rept);
END;
/


-- Performance Hub: 
/*
    Ele fornece um relatório interativo que permite ver a atividade atual, além de poder detalhar SQLs individuais. 
    Gosto de pensar neste relatório como algo “entre” o relatório ASH/AWR e um relatório de monitoramento SQL, ou seja, 
    atividade de toda a instância com foco nas instruções SQL que geram essa atividade.
*/
@$ORACLE_HOME/rdbms/admin/perfhubrpt.sql

-- @pdb remoto
spool "C:\Users\brnbe\OneDrive\Documentos\Área de Trabalho\DBMS_PERF_REPORT.html"
 select dbms_perf.report_perfhub(is_realtime=>1,type=>'active') from dual; -- is_realtime 1 and active shows the report for the last 1hour
spool off


-- AWR: Automatic Workload Repository
-- exec dbms_workload_repository.create_snapshot(); -- criação manual de snapshot 
@$ORACLE_HOME/rdbms/admin/awrrpt.sql

-- ASH: Active Session History
@$ORACLE_HOME/rdbms/admin/ashrpt.sql

-- ADDM: Automatic Database Diagnostic Monitor
@$ORACLE_HOME/rdbms/admin/addmrpt.sql




-------------------------------------------------------------------------------------------------------------------
--RAC:
AWR:  @$ORACLE_HOME/rdbms/admin/awrgrpt.sql --exec dbms_workload_repository.create_snapshot();
ASH:  @$ORACLE_HOME/rdbms/admin/ashrpti.sql
ADDM: @$ORACLE_HOME/rdbms/admin/addmrpti.sql


