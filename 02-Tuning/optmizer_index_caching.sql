--> OPTIMIZER_INDEX_CACHING (default 0)

/*
O custo de execução de um índice usando um iterador de lista IN ou de execução de uma junção de loops aninhados quando um índice é usado para acessar a tabela interna depende do armazenamento em cache 
desse índice no cache do buffer. A quantidade de cache depende de fatores que o otimizador não pode prever, como a carga do sistema e os padrões de acesso ao bloco de diferentes usuários.

Você pode modificar as suposições do otimizador sobre o cache de índice para junções de loops aninhados e iteradores da lista IN definindo esse parâmetro como um valor entre 0 e 100 
para indicar a porcentagem de blocos de índice que o otimizador deve assumir que estão no cache. Definir esse parâmetro com um valor mais alto faz com que as junções de loops aninhados e os 
iteradores da lista IN pareçam mais baratos para o otimizador. Como resultado, será mais provável escolher junções de loops aninhados em vez de junções de hash ou sort-merge e escolher índices 
usando iteradores de lista IN em vez de outros índices ou varreduras completas de tabela. O padrão para esse parâmetro é 0, o que resulta no comportamento padrão do otimizador.
*/

SELECT NAME, VALUE, display_value, DESCRIPTION  FROM v$parameter WHERE NAME = 'optimizer_index_caching';

SELECT COUNT(CASE WHEN o.object_type = 'INDEX' THEN 1 END) index_blocks,
       COUNT(CASE WHEN o.object_type = 'INDEX PARTITION' THEN 1 END) idx_part_blk,
       COUNT(CASE WHEN o.object_type = 'TABLE' THEN 1 END) table_blocks,
       COUNT(CASE WHEN o.object_type = 'TABLE PARTITION' THEN 1 END) tbl_part_blcks,
       COUNT(CASE WHEN o.object_type != 'TABLE' AND o.object_type != 'INDEX' AND o.object_type != 'TABLE PARTITION' 
                  AND o.object_type != 'INDEX PARTITION' THEN 1 END) others_blocks
  FROM dba_objects o, v$bh bh
 WHERE o.data_object_id = bh.objd;
 