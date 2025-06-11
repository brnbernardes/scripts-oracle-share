-- db_link; data base link; data_link;

-- Create
CREATE DATABASE LINK nome CONNECT TO usuario IDENTIFIED BY senha USING 'tns';
CREATE PUBLIC DATABASE LINK nome CONNECT TO usuario IDENTIFIED BY senha USING 'tns';

-- Ajuste para nome nome simples
ALTER system SET global_names = FALSE container = CURRENT scope = memory;


-- Drop dblinks in other users
DECLARE
 v_owner VARCHAR2(50):= 'OWNER';
 v_db_link VARCHAR2(50) := 'DBLINK';

BEGIN
  dbms_scheduler.create_job(
    job_name=> v_owner||'.drop_database_link',
    job_type=>'PLSQL_BLOCK',
    job_action=>'BEGIN execute immediate ''drop database link ' || v_db_link ||'''; END;');
    dbms_scheduler.run_job(v_owner || '.drop_database_link',false);
    dbms_lock.sleep(3);
    dbms_scheduler.drop_job(v_owner||'.drop_database_link');
END;
/