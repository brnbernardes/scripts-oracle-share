DECLARE
  ln_size NUMBER := 100;
  ln_updcount NUMBER;
BEGIN
  LOOP
    --> DML: UPDATE GRP_BAS_LOGRADOURO  SET TIPO = 'RUA' WHERE TIPO = 'R' AND
    rownum <= ln_size;
    ln_updcount := SQL%ROWCOUNT;    
    dbms_output.put_line(ln_count);
    EXIT WHEN ln_updcount = 0;
    COMMIT;
  END LOOP;
END;
/