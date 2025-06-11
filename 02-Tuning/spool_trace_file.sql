set serveroutput off
set pagesize 0
set echo off 
set feedback off 
set trimspool on 
set heading off
set tab off
set long 1000000
spool c:\temp\student_trace.trc

select payload 
from   v$diag_trace_file_contents
where  trace_filename = (
    select substr (
           value,
           instr ( value, '/', -1 ) + 1
         ) filename
  from   v$diag_info
  where  name = 'Default Trace File'
)
order  by line_number;

spool off 