-- Coletando estatístiscas da view complexa passada por parâmetro
BEGIN
  FOR c IN (SELECT DISTINCT owner, table_name
              FROM (SELECT a.referenced_owner owner,
                           a.referenced_name  AS table_name,
                           a.referenced_type
                      FROM all_dependencies a
                     WHERE a.owner NOT IN ('SYS', 'SYSTEM', 'PUBLIC')
                       AND a.referenced_owner NOT IN
                           ('SYS', 'SYSTEM', 'PUBLIC')
                       AND a.referenced_type != 'NON-EXISTENT'
                     START WITH a.owner = ('ERP')
                            AND a.name IN ('GRP_CTB_LOTE_CONTABIL_ITEM_V') --> Views
                    CONNECT BY a.owner = PRIOR a.referenced_owner
                           AND a.name = PRIOR a.referenced_name
                           AND a.type = PRIOR a.referenced_type)
             WHERE referenced_type = 'TABLE')
  LOOP
    BEGIN
    dbms_output.put_line (c.table_name); 
    dbms_stats.gather_table_stats(ownname => c.owner,
                                  tabname => c.table_name,
                                  estimate_percent => dbms_stats.auto_sample_size,
                                  method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                  cascade => TRUE);
    dbms_output.put_line ('OK' || CHR(10));                                   
 EXCEPTION 
   WHEN OTHERS THEN
     dbms_output.put_line (SQLERRM ||  CHR(10));                                  
   END;
  END LOOP;
END;
/


-- Table Statiscts para tabelas 
BEGIN
  FOR c IN (SELECT owner, table_name
              FROM dba_tables
             WHERE table_name LIKE '%REINF%') LOOP
    dbms_stats.gather_table_stats(ownname => c.owner,
                                  tabname => c.table_name,
                                  estimate_percent => dbms_stats.auto_sample_size,
                                  method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                  cascade => TRUE);
  END LOOP;
END;
/