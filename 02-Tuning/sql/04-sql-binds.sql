-- Binds
SELECT sql_id,
       child_number,
       position,
       datatype_string,
       NAME,  
       value_string,
       last_captured
  FROM v$sql_bind_capture
 WHERE sql_id = '2sbn44nb4ax4w';

-- Binds substituicao
SELECT DISTINCT last_captured, sql_id,
       child_number,
       datatype_string,
       name,
       NAME || ': ' ||  
       case 
          when datatype_string like 'VARCHAR%' then '''' || value_string || ''''
          when datatype_string like 'DATE%' then 'to_date(''' || value_string || ''', ''dd/mm/yyyyy'')'  
          
          else value_string end value_string               
  FROM v$sql_bind_capture
 WHERE sql_id = '7rd428rbhju1z'
 order by name;


-- Binds Hist
SELECT datatype_string, max_length, name, value_string, con_id, (SELECT NAME FROM v$pdbs WHERE con_id = dba_hist_sqlbind.con_id) PDB
  FROM dba_hist_sqlbind
 WHERE sql_id = '2sbn44nb4ax4w'
   AND last_captured = (SELECT MAX(last_captured)
                          FROM dba_hist_sqlbind
                         WHERE sql_id = '2sbn44nb4ax4w');
