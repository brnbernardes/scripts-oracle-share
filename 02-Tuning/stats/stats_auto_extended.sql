------------------------------------------------------------------------------------------------------------------------
-- Cria??o de Statistics Extended para >= 12c 
------------------------------------------------------------------------------------------------------------------------

-- Verificar parâmetro global METHOD_OPT
SELECT DBMS_STATS.GET_PREFS('method_opt') FROM dual;

-- Definir parâmetro global METHOD_OPT para FOR ALL COLUMNS SIZE 2048
BEGIN
  DBMS_STATS.set_global_prefs('method_opt', 'FOR ALL COLUMNS SIZE 2048');
END;
/

-- Verificar parâmetro global AUTO_STAT_EXTENSIONS
SELECT DBMS_STATS.GET_PREFS('AUTO_STAT_EXTENSIONS') FROM dual;

-- Definir parâmetro global AUTO_STAT_EXTENSIONS para ON
BEGIN
  DBMS_STATS.set_global_prefs('AUTO_STAT_EXTENSIONS', 'ON');
END;
/

--> * Executar query / utilizar sistema *

--> Verificando se foram criadas SQL PLAN DIRECTIVES
BEGIN
   DBMS_SPD.flush_sql_plan_directive;   
END;
/  

SELECT to_char(d.directive_id) dir_id,
       o.owner,
       o.object_name,
       o.subobject_name col_name,
       o.object_type,
       d.type,
       d.state,
       d.reason,
       d.created,
       d.last_modified,
       d.last_used
  FROM dba_sql_plan_directives  d,
       dba_sql_plan_dir_objects o
 WHERE d.directive_id = o.directive_id
   AND o.owner = 'ERP'
   AND d.created >= TRUNC(SYSDATE)
   AND d.last_used IS NULL
 ORDER BY 1,2,3,4,5;
 

--> Coletar estatísticas de alguma forma pelo dbms_stats

-- Por Schema:
BEGIN
 DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'ERP', estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE 2048', cascade => TRUE, degree => 10);
END;
/

-- Por tabela:
BEGIN
  FOR c IN (SELECT owner, table_name
              FROM dba_tables
             WHERE table_name LIKE '%REINF%') LOOP
    dbms_stats.gather_table_stats(ownname => c.owner,
                                  tabname => c.table_name,
                                  estimate_percent => dbms_stats.auto_sample_size,
                                  method_opt => 'FOR ALL COLUMNS SIZE 2048',
                                  cascade => TRUE);
  END LOOP;
END;
/

-- Verificar criação de Statistics Extended 
SELECT * FROM dba_stat_extensions WHERE owner = 'DBTW' and table_name = 'DBTW_USERN';




------------------------------------------------------------------------------------------------------------------------
-- Criação de Statistics Extended para 11G
------------------------------------------------------------------------------------------------------------------------

--> Ativmar monitoramento por 5min
BEGIN
 dbms_stats.seed_col_usage(NULL,NULL, 300);
END;
/

--> Relatório por tabela
SELECT dbms_stats.report_col_usage(ownname => 'DBTW',
                                   tabname => 'DBTW_USERN')
  FROM dual;

--> Forçar criação
SELECT dbms_stats.create_extended_stats(ownname => 'DBTW',
                                        tabname => 'DBTW_USERN')
  FROM dual;

--> Validar criação
SELECT * FROM dba_stat_extensions WHERE owner = 'DBTW' and table_name = 'DBTW_USERN';



------------------------------------------------------------------------------------------------------------------------
-- Criação de Statistics MANUAL
------------------------------------------------------------------------------------------------------------------------
SELECT DBMS_STATS.CREATE_EXTENDED_STATS(null,'&TABLE_NAME', '(&coluna1, &coluna2)') FROM DUAL;
--
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=> 'ERP', TABNAME=> '&TABLE_NAME', CASCADE=> TRUE, METHOD_OPT=> 'FOR ALL COLUMNS SIZE SKEWONLY');
--
SELECT COLUMN_NAME, NUM_DISTINCT, HISTOGRAM FROM USER_TAB_COL_STATISTICS WHERE TABLE_NAME='&TABLE_NAME';
--
    