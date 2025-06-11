-- Print Xplan for String Search
DECLARE 
 vsql VARCHAR2(4000);
 TYPE values_t IS TABLE OF VARCHAR2(4000);
 l_values   values_t;
BEGIN
  FOR c IN (SELECT 'SELECT plan_table_output FROM TABLE(dbms_xplan.display_cursor(sql_id=> ''' || sql_id || ''',cursor_child_no => ' || child_number || ', format=>''ADVANCED ALLSTATS LAST +PEEKED_BINDS''))' dbms_xplan
              FROM v$sql
             WHERE sql_text LIKE '%simula01_d2tkqnjas4j6t%'
               AND sql_text NOT LIKE '%v$sql%'
               AND executions > 0
             ORDER BY last_active_time)
  LOOP
  dbms_output.put_line(c.dbms_xplan);  
  vsql := c.dbms_xplan;
EXECUTE IMMEDIATE vsql BULK COLLECT INTO l_values;
FOR indx IN 1 .. l_values.COUNT
   LOOP
      dbms_output.put_line(l_values (indx));
   END LOOP;
END LOOP;
END;
/


/*
#Descrição:
--> OMem: Quantidade de espaço na memoria que o Oracle estima que será necessária para executar a operação.
--> 1Mem: Valor de memoria acima do qual o Oracle ainda consegue realizar a operação com “ONE-PASS WORKAREA”.
--> Used-Mem: Memoria que foi utilizada na ultima execução.
--
--> Starts: Número de vezes que a operação dessa linha foi executada.
--> E-rows: Estimativa de registros que serão entregues a operação pai por uma execução da operação dessa linha.
--> A-rows: Número acumulado de registros que serão entregues a operação pai de todas as execuções da operação dessa linha.
--> A-time: Tempo gasto na execução da operação dessa linha incluindo os tempos da operações descendentes.
--> Buffers: Número de “buffers” acessados na execução da operação dessa linha incluindo seus descendentes.
--> Reads: Número de blocos lidos do disco na execução da operação dessa linha incluído seus descendentes.
--> Writes: Número de blocos gravados em disco na execução da operação dessa linha incluindo seus descendentes.
--> Used-Tmp: Quantidade de espaço utilizando na tablespace temporária em KB para execução da operação dessa linha.

#Operações:
--- Access Paths (operations), do melhor para o pior: 
--> Tables Access by ROWID
--> Index Unique Scan
--> Index Range Scan
--> Index Range Scan descending
--> Index Skip Scan  
--> Full Index Scan (FIS)
--> Fast Full Index Scan (FFIS) *
--> Full Table Scan (FTS) * 

#O que procurar:
1) Ponto de aumento de Cost / Rows/ Bytes
2) Diferença entre A-Rows e E-Rows, staticsts desatualizadas
3) Nested Loops com grande quantidade de Starts
4) Sorte Merge / Hash Join com pequena quantidade de Rows
5) FTS / FIS / FFIS em "Filter"
6) FIS / FFIS / Index Skip Scan em "Acess"
*/