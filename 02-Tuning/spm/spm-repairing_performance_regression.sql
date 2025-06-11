--> https://blogs.oracle.com/optimizer/post/repairing-sql-performance-regression-with-sql-plan-management
BEGIN 
   --
   -- Create a SQL plan baseline for the problem query plan
   -- (in this case assuming that it is in the cursor cache)
   -- 
   n := dbms_spm.load_plans_from_cursor_cache(
                  sql_id => '<problem_SQL_ID>', 
                  plan_hash_value=> <problem_plan_hash_value>, 
                  enabled => 'no');
   --
   -- Set up evolve
   --
   tname := DBMS_SPM.CREATE_EVOLVE_TASK(sql_handle=>handle); 

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_BASELINE', 
      value     => 'EXISTING');

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_SOURCE', 
      value     => 'CURSOR_CACHE+AUTOMATIC_WORKLOAD_REPOSITORY+SQL_TUNING_SET');

   DBMS_SPM.SET_EVOLVE_TASK_PARAMETER( 
      task_name => tname,
      parameter => 'ALTERNATE_PLAN_LIMIT', 
      value     => 'UNLIMITED');
   --
   -- Evolve
   --
   ename := DBMS_SPM.EXECUTE_EVOLVE_TASK(tname);
   --
   -- Optionally, choose to implement immediately
   --
   n := DBMS_SPM.IMPLEMENT_EVOLVE_TASK(tname);
END; 
/