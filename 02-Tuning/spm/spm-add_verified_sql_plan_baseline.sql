set long 100000
set  tab off
set linesize 200
column report format a150
var report clob

exec :report := dbms_spm.add_verified_sql_plan_baseline('<your_sql_id>');
select :report report from dual;