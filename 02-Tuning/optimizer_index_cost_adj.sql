--> OPTIMIZER_INDEX_COST_ADJ (default 100): quanto menor o valor mais propenso a utilização de index 
/*
Permite ajustar o comportamento do otimizador para que a seleção do caminho de acesso seja mais ou menos amigável ao índice — ou seja, 
para tornar o otimizador mais ou menos propenso a selecionar um caminho de acesso ao índice em uma varredura completa da tabela.

O padrão para esse parâmetro é 100%, no qual o otimizador avalia os caminhos de acesso ao índice pelo custo normal. 
Qualquer outro valor faz com que o otimizador avalie o caminho de acesso naquela porcentagem do custo definida. 
Por exemplo, uma configuração de 50 faz com que o caminho de acesso ao índice pareça metade do preço normal.
*/

SELECT NAME, VALUE, display_value, DESCRIPTION  FROM v$parameter WHERE NAME = 'optimizer_index_cost_adj';

/*Determining a starting value for optimizer_index_cost_adj
We can see that the optimal setting for optimizer_index_cost_adj is partially a function of the I/O waits for sequential reads vs. scattered reads:
*/
col c1 heading 'Average Waits for|Full Scan Read I/O' format 9999.999
col c2 heading 'Average Waits for|Index Read I/O' format 9999.999
col c3 heading 'Percent of| I/O Waits|for scattered|Full Scans' format 99.99
col c4 heading 'Percent of| I/O Waits|for sequential|Index Scans' format 99.99
col c5 heading 'Starting|Value|for|optimizer|index|cost|adj' format 999
SELECT a.average_wait c1,
       b.average_wait c2,
       a.total_waits / (a.total_waits + b.total_waits) * 100 c3,
       b.total_waits / (a.total_waits + b.total_waits) * 100 c4,
       (b.average_wait / a.average_wait) * 100 c5
  FROM v$system_event a, v$system_event b
 WHERE a.event = 'db file scattered read'
   AND b.event = 'db file sequential read';


SELECT SUM(a.time_waited_micro) / SUM(a.total_waits) / 1000000 c1,
       SUM(b.time_waited_micro) / SUM(b.total_waits) / 1000000 c2,
       (SUM(a.total_waits) / SUM(a.total_waits + b.total_waits)) * 100 c3,
       (SUM(b.total_waits) / SUM(a.total_waits + b.total_waits)) * 100 c4,
       (SUM(b.time_waited_micro) / SUM(b.total_waits)) /
       (SUM(a.time_waited_micro) / SUM(a.total_waits)) * 100 c5
  FROM dba_hist_system_event a, dba_hist_system_event b
 WHERE a.snap_id = b.snap_id
   AND a.event_name = 'db file scattered read'
   AND b.event_name = 'db file sequential read';
