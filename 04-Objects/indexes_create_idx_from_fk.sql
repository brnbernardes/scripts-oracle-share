SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  FOR i IN (SELECT 'create index ERP."' || fk_name || '" on "ERP"."' ||
                   table_name || '"(' || fk_columns || ')' AS comandocreate,
                   'drop index ERP."' || fk_name || '"' AS comandodrop
              FROM (SELECT fk_name, table_name, fk_columns
                      FROM (SELECT CASE
                                     WHEN b.table_name IS NULL THEN 'unindexed'
                                     ELSE 'indexed'
                                   END AS status,
                                   a.owner,
                                   a.table_name,
                                   a.constraint_name AS fk_name,
                                   a.fk_columns,
                                   b.index_name,
                                   b.index_columns 
                              FROM (SELECT a.owner,
                                           a.table_name,
                                           a.constraint_name,
                                           listagg(a.column_name, ',') within GROUP(ORDER BY a.position) fk_columns
                                      FROM all_cons_columns a,
                                           all_constraints  b
                                     WHERE a.constraint_name =
                                           b.constraint_name
                                       AND b.constraint_type = 'R'
                                       AND a.owner = 'ERP'
                                       AND a.owner = b.owner
                                     GROUP BY a.owner,
                                              a.table_name,
                                              a.constraint_name) a,
                                   (SELECT table_name,
                                           index_name,
                                           listagg(c.column_name, ',') within GROUP(ORDER BY c.column_position) index_columns
                                      FROM all_ind_columns c
                                     WHERE c.index_owner = 'ERP'
                                     GROUP BY table_name, index_name) b
                             WHERE a.table_name = b.table_name(+)
                               AND b.index_columns(+) LIKE a.fk_columns || '%'
                             ORDER BY 1 DESC, 2)
                     WHERE status = 'unindexed')) LOOP
    BEGIN
      dbms_output.put_line(i.comandocreate);
      EXECUTE IMMEDIATE i.comandocreate;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Comando [' || i.comandodrop || ']');
        EXECUTE IMMEDIATE i.comandodrop;
        dbms_output.put_line(i.comandocreate);
        EXECUTE IMMEDIATE i.comandocreate;
    END;
  END LOOP;
END;
/