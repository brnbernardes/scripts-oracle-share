-- Columns Statistics
SELECT column_name AS "NAME",
       num_distinct AS "#DISTINCT",
       density AS "DENSITY",
       num_nulls AS "#NULL",
       avg_col_len ,
       histogram,
       num_buckets AS "#BUCKETS",
       low_value,
       high_value
  FROM dba_tab_col_statistics
 WHERE table_name = '&TABLE_NAME'
   AND owner = 'ERP';

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