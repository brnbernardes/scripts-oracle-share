SELECT component,
       ROUND(current_size / 1024 / 1024 / 1024,4) current_size_gb,
       ROUND(min_size / 1024 / 1024 / 1024,4) min_size_gb,
       ROUND(max_size / 1024 / 1024 / 1024,4) max_size_gb
  FROM v$memory_dynamic_components
  WHERE min_size >0;