/* https://richardfoote.wordpress.com/category/clustering-factor/

Exemplo: Table bowie com 200.000 registros
Index: ID 
Teste: select * from bowie where id > 1 and id < 1001
 
---------------------------------------------------------------------------------------------------------------------------------
| Id | Operation                            | Name       | Starts | E-Rows |E-Bytes| Cost (%CPU)| A-Rows | A-Time     |Buffers |
---------------------------------------------------------------------------------------------------------------------------------
|  0 | SELECT STATEMENT                     |            |      1 |        |       |    21 (100)|    999 |00:00:00.01 |     18 |
|  1 |  TABLE ACCESS BY INDEX ROWID BATCHED | BOWIE      |      1 |   1000 |   108K|      21 (0)|    999 |00:00:00.01 |     18 |
|* 2 |   INDEX RANGE SCAN                   | BOWIE_ID_I |      1 |   1000 |       |       4 (0)|    999 |00:00:00.01 |      4 |
---------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ID">1 AND "ID"<1001)


A estatística KEY que o CBO deve determinar é a seletividade estimada da consulta (a porcentagem estimada de linhas a serem retornadas), 
pois este é o impulsionador de todos os cálculos subsequentes do CBO.

A seletividade desta consulta de predicado baseada em intervalo é calculada da seguinte forma:

Seletividade = (Valor limite mais alto – Valor limite mais baixo) / (Valor mais alto – Valor mais baixo)
= (1001-1) /(200000-1)
= 1000/199999
= aprox. 0,005

Uma vez que o Oracle tenha a seletividade, ele pode calcular a cardinalidade da consulta (número estimado de linhas) da seguinte forma:

Cardinalidade = Seletividade x Número de Linhas

Cardinalidade = 0,005 x 200.000 = 1.000 linhas

Esta é a nossa janela visual para a probabilidade de o CBO ter tomado uma decisão precisa com o seu plano de execução. 
Se as estimativas de cardinalidade forem razoavelmente precisas, então o CBO provavelmente gerará um bom plano. 
Se as estimativas de cardinalidade estiverem erradas, é mais provável que o CBO gere um plano inadequado.

*/
--Indexes columns e Indexes Functions
WITH ic AS
 (SELECT /*+ no_merge(ie) */ 
         ic.index_owner,
         ic.table_name,
         ic.index_name,
         '(' || listagg(NVL(dbms_lob.substr(ie.column_expression), ic.column_name), ', ') within GROUP(ORDER BY ic.column_position) || ')' cols
    FROM dba_ind_columns ic
    LEFT OUTER JOIN  xmltable(
            '/ROWSET/ROW'
           passing dbms_xmlgen.getXMLType(
                   replace(replace('select index_owner, index_name, column_expression, column_position from dba_ind_expressions where index_name = '':1'' and index_owner = '':2''', ':1', ic.index_name), ':2', ic.index_owner))
            columns column_expression varchar2(4000) path 'COLUMN_EXPRESSION'
                  , column_position   number         path 'COLUMN_POSITION'
                  , index_name VARCHAR2(30) PATH 'INDEX_NAME'
                  , index_owner VARCHAR2(30) PATH 'INDEX_OWNER'
          ) ie
      ON ic.index_owner = ie.index_owner
      AND ic.index_name = ie.index_name
      AND ic.column_position = ie.column_position  
   WHERE ic.table_name IN ('&TABLE')
   GROUP BY ic.index_owner, ic.table_name, ic.index_name)
SELECT ic.*,
       index_type,
       i.num_rows,
       i.distinct_keys,
       i.clustering_factor,
       i.avg_data_blocks_per_key,
       i.last_analyzed,
       o.created
  FROM ic
 INNER JOIN dba_indexes i
    ON ic.index_owner = i.owner
   AND ic.index_name = i.index_name
 INNER JOIN dba_objects o
    ON i.owner = o.owner
   AND i.index_name = o.object_name
 ORDER BY ic.index_name DESC;

------------------------------------------------------------------------------------------------

select i.owner 
     , i.index_name
     , i.index_type 
     , i.table_owner 
     , i.table_name 
     , i.table_type 
     , i.uniqueness 
     , c.column_position 
     , c.column_name 
     , (select ie.column_expression from
xmltable('/ROWSET/ROW'
           passing dbms_xmlgen.getXMLType(
                   replace(
                   replace(
                   replace('select column_expression from dba_ind_expressions e where e.index_owner='':1'' and e.index_name='':2'' and e.column_position='':3'''
                        , ':1',i.owner)
                        , ':2',i.index_name)
                        , ':3',c.column_position))
            columns column_expression varchar2(4000) path 'COLUMN_EXPRESSION'
          ) ie) as column_expression
  from all_indexes i 
     , all_ind_columns c 
 where i.owner = c.index_owner 
   and i.index_name = c.index_name 
   and i.owner = 'ERP' 
   and i.index_name like 'GRP_PTL%'
 order by i.owner 
        , i.index_name 
        , c.column_position;


------------------------------------------------------------------------------------------------

WITH ic AS
(SELECT index_owner,
        table_name,
       index_name,
       '(' || listagg(column_name, ', ') within group(order by column_position) || ');' cols
  from dba_ind_columns ic 
 where table_name IN ('TRI$_NOTASFISCAIS_ISS_E')
 group by index_owner ,table_name, index_name)
SELECT ic.*, i.num_rows, i.distinct_keys , i.clustering_factor, i.avg_data_blocks_per_key, i.last_analyzed
  FROM ic
 INNER JOIN dba_indexes i
    ON ic.index_owner = i.owner
   AND ic.index_name = i.index_name
ORDER BY distinct_keys DESC;

------------------------------------------------------------------------------------------------

select table_name,
       index_name,
       '(' || listagg(column_name, ', ') within group(order by column_position) || ');' cols
  from dba_ind_columns
 where table_name IN ('BAS$_CADASTROGERAL_E',
                      'BAS$_CATEGORIA_E',
                      'BAS$_PERMISSAO_E',
                      'BAS$_PROGRAMA_E',
                      'BAS$_USUARIO_CATEGORIA_E',
                      'BAS$_USUARIO_E')
 group by table_name, index_name;


SELECT index_name, visibility, num_rows, distinct_keys , clustering_factor, avg_data_blocks_per_key, last_analyzed
   FROM dba_indexes i
  WHERE table_name IN ('TRI$_IMPOSTO_E');

SELECT table_name,
       index_name,
       '(' || listagg(column_name, ', ') within GROUP(ORDER BY column_position) || ');' columns
  FROM dba_ind_columns
 WHERE table_name IN ('TRI$_IMPOSTO_E')
 GROUP BY table_name, index_name;