--> Coleta geral: GATHER STALE (SELECT * FROM dba_tab_modifications)
BEGIN
  dbms_stats.gather_database_stats(estimate_percent => dbms_stats.auto_sample_size,
                                   block_sample => FALSE,
                                   degree => 8,
                                   granularity => 'AUTO',
                                   cascade => TRUE,
                                   options => 'GATHER STALE',
                                   gather_sys => FALSE,
                                   no_invalidate => FALSE,
                                   method_opt => 'FOR ALL COLUMNS SIZE AUTO');
END;
/

--> Coleta geral: GATHER EMPTY
BEGIN
  dbms_stats.gather_database_stats(estimate_percent => dbms_stats.auto_sample_size,
                                   block_sample => FALSE,
                                   degree => 8,
                                   granularity => 'AUTO',
                                   cascade => TRUE,
                                   options => 'GATHER EMPTY',
                                   gather_sys => FALSE,
                                   no_invalidate => FALSE,
                                   method_opt => 'FOR ALL COLUMNS SIZE AUTO');
END;
/

--> Coleta geral: FULL
BEGIN
  dbms_stats.gather_database_stats(estimate_percent => dbms_stats.auto_sample_size,
                                   block_sample => FALSE,
                                   --degree => 8,
                                   granularity => 'AUTO',
                                   cascade => TRUE,
                                   options => 'GATHER', --> default
                                   gather_sys => FALSE,
                                   no_invalidate => FALSE,
                                   method_opt => 'FOR ALL COLUMNS SIZE AUTO');
END;
/

--> Tabelas analisadas
SELECT owner, trunc(last_analyzed), COUNT(1)
  FROM dba_tab_statistics
  WHERE owner = 'ERP'
 GROUP BY owner, trunc(last_analyzed)
ORDER BY 2 DESC,1;

-- History Operations
SELECT id,
       operation,
       target,               
       start_time,                          
       end_time,                            
       status,
       job_name
  FROM dba_optstat_operations;  

-- All statistics
EXEC DBMS_STATS.GATHER_DATABASE_STATS (gather_sys=>TRUE);

-- Fixed Objects Statistics (V$SQL, V$SESSION, etc.)
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;

-- Dictionary Statistics (DBA_SEGMENTS, DBA_TABLES, etc.);
EXEC  DBMS_STATS.GATHER_DICTIONARY_STATS;

-- System Statistcs (CPU e I/O)
EXEC  DBMS_STATS.GATHER_SYSTEM_STATS;

-- Extended statistics
SELECT DBMS_STATS.CREATE_EXTENDED_STATS('OWNER', 'TABLE', '(col1,col2)') from dual;

-- Schema statistics
exec DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'ERP', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE, degree => 10);

-- Statistics Table Block
SELECT ts.owner,
       ts.table_name,
       ts.stattype_locked,
       t.num_rows,
       t.last_analyzed,
       t.temporary,
       'SELECT count(1) as "' || ts.table_name || '" FROM ' || ts.owner || '.' || ts.table_name || ';',
       'exec dbms_stats.unlock_table_stats(' || '''' || ts.owner || ''',''' || ts.table_name || ''');' unlock_table_stats
  FROM dba_tab_statistics ts
 INNER JOIN dba_tables t
    ON ts.owner = t.owner
   AND ts.table_name = t.table_name
 WHERE ts.owner = 'ERP'
   AND ts.stattype_locked IS NOT NULL;

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



exec dbms_stats.gather_table_stats(ownname => 'CURSO02', tabname => 'DBTW115', estimate_percent => dbms_stats.auto_sample_size, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE); 
exec dbms_stats.gather_table_stats(ownname => 'SH', tabname => 'CUSTOMERS', estimate_percent => dbms_stats.auto_sample_size, method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE); 

BEGIN 
 dbms_stats.gather_schema_stats(ownname => 'ERP', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, options=> 'GATHER', granularity => 'AUTO', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);
END;
/