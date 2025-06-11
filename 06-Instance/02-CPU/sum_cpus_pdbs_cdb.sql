SELECT con_id,
       to_number(VALUE)
  FROM v$system_parameter
 WHERE NAME = 'cpu_count'
ORDER BY 1;
