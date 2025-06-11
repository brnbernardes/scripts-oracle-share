WITH tab_seq AS (
SELECT t.owner,
       t.table_name,
       t.trigger_name,       
       d.referenced_name sequence_name,
       trim(upper(s.text))               
  FROM dba_source s
 INNER JOIN dba_triggers t
    ON t.owner = s.owner
   AND t.trigger_name = s.name
 INNER JOIN dba_dependencies d
   ON d.owner = t.owner
   AND d.name = t.trigger_name
 WHERE s.owner = 'ERP'
   AND upper(s.text) like '%_S.NEXTVAL%'
   AND s.type like 'TRIGGER'
   AND d.referenced_type = 'SEQUENCE') 
   
SELECT tab_seq.*, se.last_number FROM tab_seq 
INNER JOIN dba_sequences se
ON tab_seq.owner = se.sequence_owner
AND tab_seq.sequence_name = se.sequence_name;