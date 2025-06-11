-----------------------------
--Progress INSERT
--
SELECT sum(rows_processed) FROM v$sqlarea WHERE sql_text LIKE 'insert into GRP_SVM_CATALOGO_TEMP%' AND last_active_time >= trunc(sysdate);