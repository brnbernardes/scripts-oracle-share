
-- vim alterar encoding sqlfile 
set fileencoding=iso-8859-1


set lines 200 
set pages 50000
column NAME_COL_PLUS_SHOW_PARAM format A40
column VALUE_COL_PLUS_SHOW_PARAM format A100

--Se o dado de entrada estiver codificado em ambiente Windows:
export NLS_LANG='AMERICAN_AMERICA.WE8MSWIN1252'
export NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.WE8MSWIN1252'

--Em ISO-8859-P1 (Unix):
export NLS_LANG='AMERICAN_AMERICA.WE8ISO8859P1'
export NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.WE8ISO8859P1'

--Em UTF-8:
export NLS_LANG='AMERICAN_AMERICA.AL32UTF8'

--Sempre definir
ALTER SESSION SET NLS_LANGUAGE= 'BRAZILIAN PORTUGUESE' NLS_TERRITORY= 'BRAZIL';

--------------------------------------------------------------------------------------------
-- sqlplus parameters
$ORACLE_HOME/sqlplus/admin/glogin.sql
set lines 300 pages 999
set feed off
set time on
col sessiontimezone for a25
col current_timestamp for a40
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';
define gname=idle
column global_name new_value gname
set heading off
set termout off
col global_name noprint
select upper(sys_context ('userenv', 'session_user') || '@' || sys_context('userenv', 'con_name')) global_name from dual;
set sqlprompt '&gname> '
set heading on
set termout on
set feed on


--------------------------------------------------------------------------------------------
-- sqlplus parameters
$ORACLE_HOME/sqlplus/admin/glogin.sql

set termout off
COLUMN 1 NEW_VALUE 1 noprint
COLUMN 2 NEW_VALUE 2 noprint
COLUMN 3 NEW_VALUE 3 noprint
COLUMN 4 NEW_VALUE 4 noprint
COLUMN 5 NEW_VALUE 5 noprint
COLUMN 6 NEW_VALUE 6 noprint
COLUMN 7 NEW_VALUE 7 noprint
COLUMN 8 NEW_VALUE 8 noprint
COLUMN 9 NEW_VALUE 9 noprint
COLUMN 10 NEW_VALUE 10 noprint
COLUMN 11 NEW_VALUE 11 noprint
COLUMN 12 NEW_VALUE 12 noprint
COLUMN 13 NEW_VALUE 13 noprint
COLUMN 14 NEW_VALUE 14 noprint
COLUMN 15 NEW_VALUE 15 noprint
COLUMN 16 NEW_VALUE 16 noprint
SELECT '' "1", '' "5", '' "9",  '' "13"
      ,'' "2", '' "6", '' "10", '' "14"
      ,'' "3", '' "7", '' "11", '' "15"
      ,'' "4", '' "8", '' "12", '' "16"
FROM dual;
set termout on;