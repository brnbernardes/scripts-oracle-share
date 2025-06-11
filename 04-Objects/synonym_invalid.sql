
--SINÔNIMOS INVÁLIDOS
 SELECT s.owner,
       s.synonym_name,
       s.table_owner, 
       s.table_name
FROM   dba_synonyms s
INNER JOIN dba_objects o
      ON o.owner = s.owner
      AND o.object_name = s.synonym_name
WHERE  s.db_link IS NULL
AND    EXISTS (SELECT 1
                   FROM   dba_objects o
                   WHERE  o.owner       = s.table_owner
                   AND    o.object_name = s.table_name
                   AND    o.object_type != 'SYNONYM')
AND    s.table_owner = 'ERP' --  NOT IN ('SYS','SYSTEM')
AND    s.owner = 'PUBLIC'
AND    o.status <> 'VALID'
ORDER BY s.owner, s.synonym_name;

--LOOP NA CADEIA DE SINÔNIMOS 
SELECT s.owner,
       s.synonym_name,
       s.table_owner, 
       s.table_name
FROM   dba_synonyms s
WHERE  s.db_link IS NULL
AND    NOT EXISTS (SELECT 1
                   FROM   dba_objects o
                   WHERE  o.owner       = s.table_owner
                   AND    o.object_name = s.table_name
                   AND    o.object_type != 'SYNONYM')
AND    s.table_owner = 'ERP' -- NOT IN ('SYS','SYSTEM')
ORDER BY s.owner, s.synonym_name;



--V2 CREATE OR REPLACE SYONYNS INVÁLIDOS
BEGIN
  FOR c_exec IN (SELECT 'CREATE OR REPLACE PUBLIC SYNONYM ' || s.synonym_name || ' FOR ' || s.table_owner || '.' || s.table_name cmd
                   FROM dba_synonyms s
                  INNER JOIN dba_objects o
                     ON o.owner = s.owner
                    AND o.object_name = s.synonym_name
                  WHERE s.db_link IS NULL
                    AND EXISTS (SELECT 1
                           FROM dba_objects o
                          WHERE o.owner = s.table_owner
                            AND o.object_name = s.table_name
                            AND o.object_type != 'SYNONYM')
                    AND s.table_owner = 'ERP' --  NOT IN ('SYS','SYSTEM')
                    AND s.owner = 'PUBLIC'
                    AND o.status <> 'VALID'
                  ORDER BY s.owner, s.synonym_name) LOOP
    BEGIN
      EXECUTE IMMEDIATE c_exec.cmd;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(c_exec.cmd || chr(10) || sqlerrm);
    END;
  END LOOP;
END;
/

--V1
BEGIN
  FOR c_exec IN (WITH syn AS
                    (SELECT *
                      FROM dba_synonyms s
                     INNER JOIN dba_objects o
                        ON o.owner = s.owner
                       AND o.object_name = s.synonym_name
                     WHERE o.owner = 'PUBLIC'
                       AND o.object_type LIKE 'SYNONYM'
                       AND o.status <> 'VALID')
                   
                   SELECT 'CREATE OR REPLACE PUBLIC SYNONYM ' || syn.synonym_name || ' FOR ' || syn.table_owner || '.' || syn.table_name cmd
                     FROM syn
                    INNER JOIN dba_objects o
                       ON o.owner = 'ERP'
                      AND o.object_name = syn.object_name
                    WHERE o.object_type <> 'SYNONYM') LOOP
    BEGIN
      EXECUTE IMMEDIATE c_exec.cmd;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(c_exec.cmd || chr(10) || sqlerrm);
    END;
  END LOOP;
END;
/

                    
