select
   tablespace_name, table_name,round((blocks*8)/1024/1024,2) "size (gb)" ,
   round((num_rows*avg_row_len/1024)/1024/1024,2) "actual_data (gb)",
   (round((blocks*8/1024/1024),2) - round((num_rows*avg_row_len/1024)/1024/1024,2)) "wasted_space (gb)"
from
   dba_tables
where
   (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 4 desc;