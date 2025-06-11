---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sum reason(s) for child cursors
DECLARE
  v_count number;
  v_sql varchar2(500);
  v_sql_id varchar2(30) := '&sql_id';
BEGIN
  v_sql_id := lower(v_sql_id);
  --dbms_output.put_line(chr(13)||chr(10));
  dbms_output.put_line('sql_id: '||v_sql_id);
  dbms_output.put_line('------------------------');
  FOR c1 in
    (select column_name 
       from dba_tab_columns
      where table_name ='V_$SQL_SHARED_CURSOR'
        and column_name not in ('SQL_ID', 'ADDRESS', 'CHILD_ADDRESS', 'CHILD_NUMBER', 'REASON', 'CON_ID')
      order by column_id)
  LOOP
    v_sql := 'select count(*) from V$SQL_SHARED_CURSOR
              where sql_id='||''''||v_sql_id||''''||'
              and '||c1.column_name||'='||''''||'Y'||'''';
    execute immediate v_sql into v_count;
    IF v_count > 0
    THEN
      dbms_output.put_line(' - '||rpad(c1.column_name,30)||' count: '||v_count);
    END IF;
  END LOOP;
END;
/

-- Montar query abaixo de acordo com retorno do bloco acima
SELECT sc.sql_id,
       sc.child_number,
       s.plan_hash_value,
       s.elapsed_time,
       optimizer_mismatch,
       use_feedback_stats,
       s.last_active_time,
       sc.reason
  FROM v$sql_shared_cursor sc
 INNER JOIN v$sql s
    ON sc.sql_id = s.sql_id
   AND sc.child_number = s.child_number
 WHERE s.sql_id = '0jnnjbb6w4gkc'
ORDER BY last_active_time ;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Múltiplos childs
SELECT parsing_schema_name, sql_id, sql_fulltext, version_count
  FROM v$sqlarea
 WHERE version_count > 1
AND  parsing_schema_name = 'ERP'
 ORDER BY version_count DESC;
 
 
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Identificar caso
SELECT sql_id, sql_fulltext, version_count
  FROM v$sqlarea
 WHERE sql_id = 'xxxxxx'
 ORDER BY version_count DESC;

SELECT * FROM v$sql_shared_cursor WHERE sql_id = '1tv3fzgp1ubdp';

SELECT DISTINCT v$sqlarea.con_id,
       (SELECT NAME FROM v$pdbs WHERE con_id = v$sqlarea.con_id) con_name,
       v$sqlarea.parsing_schema_name,
       v$sqlarea.sql_id,
       v$sqlarea.version_count,
       --v$sqlarea.sql_fulltext,
       --v$sql_shared_cursor.child_number,
       v$sql_shared_cursor.pq_slave_mismatch,   
       v$sql_shared_cursor.px_mismatch 
  FROM v$sqlarea
 INNER JOIN v$sql_shared_cursor
    ON v$sqlarea.con_id = v$sql_shared_cursor.con_id
   AND v$sqlarea.sql_id = v$sql_shared_cursor.sql_id
   AND v$sqlarea.address = v$sql_shared_cursor.address
 WHERE version_count > 2
   AND parsing_schema_name = 'ERP'
   AND (v$sql_shared_cursor.pq_slave_mismatch = 'Y' OR v$sql_shared_cursor.px_mismatch = 'Y')
 ORDER BY version_count DESC;

SELECT * FROM v$sql_shared_cursor WHERE sql_id = '1b4wru221rk94';


---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Determine Top-5 child cursors
select * from
   (select sql_id, count(child_number)
      from v$sql_shared_cursor
     group by sql_id
     order by count(child_number) desc)
where rownum <=5;




---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Reasons XML
SELECT 
    '&sql_id' nonshared_sql_id
  , EXTRACTVALUE(VALUE(xs), '/ChildNode/ChildNumber') nonshared_child
  , EXTRACTVALUE(VALUE(xs), '/ChildNode/reason') || ': ' ||  EXTRACTVALUE(VALUE(xs), '/ChildNode/details') nonshared_reason_and_details
  , VALUE(xs) reason_xml
FROM TABLE (
    SELECT XMLSEQUENCE(EXTRACT(d, '/Cursor/ChildNode')) val FROM (
        SELECT 
            --XMLElement("Cursor", XMLAgg(x.extract('/doc/ChildNode')))
            -- the XMLSERIALIZE + XMLTYPE combo is included for avoiding a crash in qxuageag() XML aggregation function
            XMLTYPE (XMLSERIALIZE( DOCUMENT XMLElement("Cursor", XMLAgg(x.extract('/doc/ChildNode')))) ) d
        FROM 
            v$sql_shared_cursor c
          , TABLE(XMLSEQUENCE(XMLTYPE('<doc>'||c.reason||'</doc>'))) x
        WHERE
          c.sql_id = '&sql_id' and c.child_number < 100
    )
) xs
/


---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Reasons
SELECT reason_not_shared, COUNT(*) cursors, COUNT(DISTINCT sql_id) sql_ids
  FROM v$sql_shared_cursor unpivot(val FOR reason_not_shared IN(unbound_cursor,
                                                                sql_type_mismatch,
                                                                optimizer_mismatch,
                                                                outline_mismatch,
                                                                stats_row_mismatch,
                                                                literal_mismatch,
                                                                force_hard_parse,
                                                                explain_plan_cursor,
                                                                buffered_dml_mismatch,
                                                                pdml_env_mismatch,
                                                                inst_drtld_mismatch,
                                                                slave_qc_mismatch,
                                                                typecheck_mismatch,
                                                                auth_check_mismatch,
                                                                bind_mismatch,
                                                                describe_mismatch,
                                                                language_mismatch,
                                                                translation_mismatch,
                                                                bind_equiv_failure,
                                                                insuff_privs,
                                                                insuff_privs_rem,
                                                                remote_trans_mismatch,
                                                                logminer_session_mismatch,
                                                                incomp_ltrl_mismatch,
                                                                overlap_time_mismatch,
                                                                edition_mismatch,
                                                                mv_query_gen_mismatch,
                                                                user_bind_peek_mismatch,
                                                                typchk_dep_mismatch,
                                                                no_trigger_mismatch,
                                                                flashback_cursor,
                                                                anydata_transformation,
                                                                pddl_env_mismatch,
                                                                top_level_rpi_cursor,
                                                                different_long_length,
                                                                logical_standby_apply,
                                                                diff_call_durn,
                                                                bind_uacs_diff,
                                                                plsql_cmp_switchs_diff,
                                                                cursor_parts_mismatch,
                                                                stb_object_mismatch,
                                                                crossedition_trigger_mismatch,
                                                                pq_slave_mismatch,
                                                                top_level_ddl_mismatch,
                                                                multi_px_mismatch,
                                                                bind_peeked_pq_mismatch,
                                                                mv_rewrite_mismatch,
                                                                roll_invalid_mismatch,
                                                                optimizer_mode_mismatch,
                                                                px_mismatch,
                                                                mv_staleobj_mismatch,
                                                                flashback_table_mismatch,
                                                                litrep_comp_mismatch,
                                                                plsql_debug,
                                                                load_optimizer_stats,
                                                                acl_mismatch,
                                                                flashback_archive_mismatch,
                                                                lock_user_schema_failed,
                                                                remote_mapping_mismatch,
                                                                load_runtime_heap_failed,
                                                                hash_match_failed,
                                                                purged_cursor,
                                                                bind_length_upgradeable,
                                                                use_feedback_stats))
 WHERE val = 'Y'
 GROUP BY reason_not_shared
 ORDER BY 2 DESC, 3, 1;
