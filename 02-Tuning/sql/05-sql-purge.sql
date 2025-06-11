-- Purge from Shared Pool: SQL_ID
BEGIN
  FOR sqlx IN (SELECT address, hash_value
                 FROM v$sql
                WHERE sql_id = '&SQL_ID'
                  --AND child_number = '&child_number'
                  )
  LOOP
    sys.dbms_shared_pool.purge('' || sqlx.address || ',' || sqlx.hash_value || '', 'C');
  END LOOP;
END;
/

-- Purge from Shared Pool: ALL TEXT
BEGIN
FOR sqlx in (select ADDRESS, HASH_VALUE  from v$sql WHERE sql_id = '')
LOOP
 SYS.DBMS_SHARED_POOL.PURGE(''||sqlx.address||','||sqlx.hash_value||'', 'C');
END LOOP;
END;
/