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
#Descri��o:
--> OMem: Quantidade de espa�o na memoria que o Oracle estima que ser� necess�ria para executar a opera��o.
--> 1Mem: Valor de memoria acima do qual o Oracle ainda consegue realizar a opera��o com �ONE-PASS WORKAREA�.
--> Used-Mem: Memoria que foi utilizada na ultima execu��o.
--
--> Starts: N�mero de vezes que a opera��o dessa linha foi executada.
--> E-rows: Estimativa de registros que ser�o entregues a opera��o pai por uma execu��o da opera��o dessa linha.
--> A-rows: N�mero acumulado de registros que ser�o entregues a opera��o pai de todas as execu��es da opera��o dessa linha.
--> A-time: Tempo gasto na execu��o da opera��o dessa linha incluindo os tempos da opera��es descendentes.
--> Buffers: N�mero de �buffers� acessados na execu��o da opera��o dessa linha incluindo seus descendentes.
--> Reads: N�mero de blocos lidos do disco na execu��o da opera��o dessa linha inclu�do seus descendentes.
--> Writes: N�mero de blocos gravados em disco na execu��o da opera��o dessa linha incluindo seus descendentes.
--> Used-Tmp: Quantidade de espa�o utilizando na tablespace tempor�ria em KB para execu��o da opera��o dessa linha.

#Opera��es:
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
2) Diferen�a entre A-Rows e E-Rows, staticsts desatualizadas
3) Nested Loops com grande quantidade de Starts
4) Sorte Merge / Hash Join com pequena quantidade de Rows
5) FTS / FIS / FFIS em "Filter"
6) FIS / FFIS / Index Skip Scan em "Acess"
*/