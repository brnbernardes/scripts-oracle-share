set echo on tab off;
SELECT endpoint_number,
       endpoint_number - nvl(prev_endpoint,0)  frequency,
       hex_val,
       chr(to_number(substr(hex_val, 2,2),'XX')) ||
       chr(to_number(substr(hex_val, 4,2),'XX')) ||
       chr(to_number(substr(hex_val, 6,2),'XX')) ||
       chr(to_number(substr(hex_val, 8,2),'XX')) ||
       chr(to_number(substr(hex_val,10,2),'XX')) ||
       chr(to_number(substr(hex_val,12,2),'XX')) ||
       chr(to_number(substr(hex_val,14,2),'XX')) ||
       chr(to_number(substr(hex_val,16,2),'XX')) ||
       chr(to_number(substr(hex_val,18,2),'XX')) ||
       chr(to_number(substr(hex_val,20,2),'XX')) Value
  FROM (SELECT endpoint_number,
               lag(endpoint_number,1) over(order by endpoint_number)  prev_endpoint,
               to_char(endpoint_value,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') hex_val,
               endpoint_actual_value
          FROM dba_tab_histograms
         WHERE owner = 'CURSO01'
           AND table_name = 'MYINDEXES'
           AND column_name = 'INDEX_TYPE')
 ORDER BY endpoint_number;

SELECT DISTINCT index_type FROM myindexes ORDER BY 1;
