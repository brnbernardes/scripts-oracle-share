-- Diplay Plan Time (dplant)   
SELECT id
       ,LPAD (' ', depth) || operation ||  CASE WHEN options IS NOT NULL THEN ' (' || options || ')' ELSE NULL END operation
       ,object_name
       ,last_elapsed_time elapsed
       ,last_cr_buffer_gets buffers
       ,sp.access_predicates acess
       ,sp.filter_predicates predicate
       ,last_starts
       ,last_output_rows actual_rows       
       ,cardinality
       ,bytes
       ,last_output_rows 
  FROM v$sql_plan_statistics_all sp
 WHERE sql_id = 'f9v5819yb4k2n'
   AND child_number = 3
   AND NVL(last_execution, 'NULL') <> 'OPTIMAL';   