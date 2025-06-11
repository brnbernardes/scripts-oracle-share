
/*
1) Antes da execução alguns pré-requisitos serão necessários.
- Usuï¿½rio com Privil?gio SYSDBA (Normalmente executado com usuï¿½rio SYS).
- Parâmetro TIMED_STATISTICS=TRUE
- ASYNCH_IO habilitado para todos os datafiles (par?metro)

2) O tempo de execuï¿½ï¿½o est? diretamente ligado a alguns fatores:
- Performance na estrutura de Armazenamento (Storage);
- N?mero de Datafiles;
- Tamanho do Database;
- Storage compartilhados, por exemplo ambiente clusterizado, a performance pode variar tamb?m de acordo com o nï¿½mero de Nodes do Cluster.
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


-- Esta view apresenta somente a ï¿½ltima execuï¿½ï¿½o:
col end_time for a30
col start_time for a30
SELECT * FROM dba_rsrc_io_calibrate;


--A sugestï¿½o ï¿½ alterar a execuï¿½ï¿½o de CALIBRATE_IO para armazenar cada execuï¿½ï¿½o em uma tabela auxilar:
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

Os resultados acima demonstram o mï¿½ximo atingido em operaï¿½ï¿½es de Leitura nos discos do Storage.
O melhor resultado obtido foi de 428 operaï¿½ï¿½es de I/O por Segundo (em mï¿½dia), com latï¿½ncia de 8ms. 
Para calcular a mï¿½dia de I/O por segundo em cada disco, basta dividir este valor pelo nï¿½mero de discos: 428/4 = 107 operaï¿½ï¿½es de I/O por segundo para cada disco do Storage.
Com estes resultados ï¿½ possï¿½vel gerar um grï¿½fico de consumo de I/O e throughput com o resumo de execuï¿½ï¿½o.


Como demonstrado no Grï¿½fico acima, o aumento (tolerï¿½ncia) de latï¿½ncia em milisegundos para operaï¿½ï¿½es no Banco de Dados nï¿½o gera um aumento significativo de throughput nos discos do Storage. 
Para operaï¿½ï¿½es em Banco de Dados (OLTP) a recomendaï¿½ï¿½o ï¿½ manter o tempo mï¿½dio de latï¿½ncia abaixo de 10ms. 
O throughput do Storage em MB permaneceu o mesmo durante todo o teste, atingindo media de 176MB/s por operaï¿½ï¿½o de I/O.

Observaï¿½ï¿½es importantes:
- Neste cenï¿½rio, para aumentar o mï¿½ximo de operaï¿½ï¿½es de I/O por Segundo, ï¿½ nï¿½cessï¿½rio o aumentar nï¿½ de discos no Storage ou ainda discos com maior performance.
- O Nï¿½mero mï¿½ximo de operaï¿½ï¿½es de I/O pode ou nï¿½o atender as necessidades de uma determinada aplicaï¿½ï¿½o. Isso dependerï¿½ das operaï¿½ï¿½es que a aplicaï¿½ï¿½o irï¿½ solicitar ao banco de dados.
- Relatï¿½rios AWR podem tambï¿½m ajudar a encontrar alta latï¿½ncia em requisiï¿½ï¿½es de I/O ao Banco de Dados.
Os resultados se alternam conforme a configuraï¿½ï¿½o de Hardware e Software de cada ambiente analisado. 
ï¿½ importante manter um throughput compatï¿½vel com a necessidade do Banco de Dados afim de evitar problemas de performance no acesso ï¿½ aplicaï¿½ï¿½es.

*/