-- Verificar tamanho dos tipos de segmentos na tablespace
SELECT owner, segment_type, round(sum(bytes / 1024 / 1024 / 1024), 2) gbytes
  FROM dba_segments
 WHERE tablespace_name = '&OLD_TABLESPACE'
GROUP BY owner, segment_type;

-- Move INDEXES e TABLES new tablespace
BEGIN
  FOR c IN (SELECT DISTINCT segment_type,
                            owner,
                            segment_name,
                            CASE
                              WHEN segment_type = 'TABLE' THEN 'alter table ' || owner || '.' || segment_name || ' move tablespace &NEW_TABLESPACE' 
                               WHEN segment_type = 'INDEX' THEN 'alter index ' || owner || '.' || segment_name || ' rebuild tablespace &NEW_TABLESPACE'
                              ELSE NULL
                            END cmd
              FROM dba_segments
             WHERE segment_type IN ('TABLE', 'INDEX')
             AND tablespace_name = '&OLD_TABLESPACE') LOOP
    BEGIN
      dbms_output.put_line(c.cmd);
      EXECUTE IMMEDIATE c.cmd;
      dbms_output.put_line('OK');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
  END LOOP;
END;
/

-- Move LOBS  new tablespace
BEGIN
  FOR c IN (SELECT 'ALTER TABLE ' || owner || '.' || table_name || ' MOVE LOB( ' || column_name || ') STORE AS (TABLESPACE &NEW_TABLESPACE)' cmd
              FROM dba_lobs
             WHERE tablespace_name = '&OLD_TABLESPACE') LOOP
    BEGIN
      dbms_output.put_line(c.cmd);
      EXECUTE IMMEDIATE c.cmd;
      dbms_output.put_line('OK');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
    END;
  END LOOP;
END;
/