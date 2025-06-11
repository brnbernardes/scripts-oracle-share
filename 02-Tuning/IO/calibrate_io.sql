
/*
1) Antes da execu��o alguns pr�-requisitos ser�o necess�rios.
- Usu�rio com Privil?gio SYSDBA (Normalmente executado com usu�rio SYS).
- Par�metro TIMED_STATISTICS=TRUE
- ASYNCH_IO habilitado para todos os datafiles (par?metro)

2) O tempo de execu��o est? diretamente ligado a alguns fatores:
- Performance na estrutura de Armazenamento (Storage);
- N?mero de Datafiles;
- Tamanho do Database;
- Storage compartilhados, por exemplo ambiente clusterizado, a performance pode variar tamb?m de acordo com o n�mero de Nodes do Cluster.
*/


col name format a50
SELECT name, asynch_io FROM v$datafile f,v$iostat_file i
WHERE f.file#        = i.file_no
AND filetype_name  = 'Data File'
/


-- Execu??o:
SET TIMING ON
SET SERVEROUTPUT ON
DECLARE
  lat  INTEGER;
  iops INTEGER;
  mbps INTEGER;
BEGIN
-- DBMS_RESOURCE_MANAGER.CALIBRATE_IO ( disks, max_latency, iops, mbps, lat);
   DBMS_RESOURCE_MANAGER.CALIBRATE_IO (2, 10, iops, mbps, lat);
   DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
   DBMS_OUTPUT.PUT_LINE ('latency  = ' || lat);
   dbms_output.put_line('max_mbps = ' || mbps);
end;
/


-- Esta view apresenta somente a �ltima execu��o:
col end_time for a30
col start_time for a30
SELECT * FROM dba_rsrc_io_calibrate;


--A sugest�o � alterar a execu��o de CALIBRATE_IO para armazenar cada execu��o em uma tabela auxilar:
CREATE TABLE dba_thema.dba_rsrc_io_calibrate AS SELECT * FROM dba_rsrc_io_calibrate WHERE 1=2;

DECLARE
  lat  INTEGER;
  iops INTEGER;
  mbps INTEGER;
BEGIN
   DBMS_RESOURCE_MANAGER.CALIBRATE_IO (2, 10, iops, mbps, lat);
  insert into CALIBRATE_REPORT as select * from DBA_RSRC_IO_CALIBRATE;
end;
/



/*
Interpretando Resultados:

MAX_IOPS   MAX_MBPS  MAX_PMBPS    LATENCY NUM_PHYSICAL_DISKS
-------- ---------- ---------- ---------- ------------------
     428        176         77          8                  4
     524        173         76         21                  4
     537        183         74         28                  4
     598        174         78         38                  4

Os resultados acima demonstram o m�ximo atingido em opera��es de Leitura nos discos do Storage.
O melhor resultado obtido foi de 428 opera��es de I/O por Segundo (em m�dia), com lat�ncia de 8ms. 
Para calcular a m�dia de I/O por segundo em cada disco, basta dividir este valor pelo n�mero de discos: 428/4 = 107 opera��es de I/O por segundo para cada disco do Storage.
Com estes resultados � poss�vel gerar um gr�fico de consumo de I/O e throughput com o resumo de execu��o.


Como demonstrado no Gr�fico acima, o aumento (toler�ncia) de lat�ncia em milisegundos para opera��es no Banco de Dados n�o gera um aumento significativo de throughput nos discos do Storage. 
Para opera��es em Banco de Dados (OLTP) a recomenda��o � manter o tempo m�dio de lat�ncia abaixo de 10ms. 
O throughput do Storage em MB permaneceu o mesmo durante todo o teste, atingindo media de 176MB/s por opera��o de I/O.

Observa��es importantes:
- Neste cen�rio, para aumentar o m�ximo de opera��es de I/O por Segundo, � n�cess�rio o aumentar n� de discos no Storage ou ainda discos com maior performance.
- O N�mero m�ximo de opera��es de I/O pode ou n�o atender as necessidades de uma determinada aplica��o. Isso depender� das opera��es que a aplica��o ir� solicitar ao banco de dados.
- Relat�rios AWR podem tamb�m ajudar a encontrar alta lat�ncia em requisi��es de I/O ao Banco de Dados.
Os resultados se alternam conforme a configura��o de Hardware e Software de cada ambiente analisado. 
� importante manter um throughput compat�vel com a necessidade do Banco de Dados afim de evitar problemas de performance no acesso � aplica��es.

*/