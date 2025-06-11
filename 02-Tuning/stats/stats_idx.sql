-- Verificação de índices 
/*
Quatro fatores trabalham juntos para ajudar o CBO a decidir se deve usar um índice ou uma varredura de tabela completa:
 -> the selectivity of a column value
 -> the db_block_size 
 -> the avg_row_len
 -> the cardinality

Uma varredura de índice geralmente é mais rápida se uma coluna de dados tiver alta seletividade e um baixo fator de clustering.
*/

 SELECT index_name,
        num_rows,
        distinct_keys,
        visibility,
        last_analyzed
      FROM dba_indexes
     WHERE table_name = 'CTB$_LANCAMENTO_ORCAMENTARIO_E'
     ORDER BY index_name;

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
   WHERE ic.table_name IN ('TRI$_NOTASFISCAIS_ISS_E')
   GROUP BY ic.index_owner, ic.table_name, ic.index_name)
SELECT ic.*,
       index_type,
       i.num_rows,
       i.distinct_keys,
       i.clustering_factor,
       i.leaf_blocks,
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