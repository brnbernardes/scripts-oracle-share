SELECT client_name, status FROM dba_autotask_client;

BEGIN
  dbms_auto_task_admin.enable(client_name => 'sql tuning advisor',
                              operation => NULL, 
                              window_name => NULL);
END;
/
