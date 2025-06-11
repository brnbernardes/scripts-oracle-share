SELECT tc.owner,
       tc.table_name,
       tc.column_name,
       tc.data_type
       tc.data_length,
       tc.data_precision,
       tc.nullable,
       cc.comments
  FROM dba_tables t
 INNER JOIN dba_tab_columns tc
    ON t.owner = tc.owner
   AND t.table_name = tc.table_name
 LEFT JOIN dba_col_comments cc
    ON tc.owner = cc.owner
   AND tc.table_name = cc.table_name
   AND tc.column_name = cc.column_name
 WHERE t.owner = 'ERP'
   AND t.temporary = 'N'
   AND (t.table_name like 'CTB$%' or t.table_name like 'GRP_CTB%' or
       t.table_name in ('BAS$_CADASTROGERAL_E',
                         'BAS$_INFOCREDOR_E',
                         'BAS$_LOCALFISICO_E',
                         'BAS$_GRUPO_PLANO_CONTABIL_E',
                         'BAS$_OPERACAO_CONTABIL_E',
                         'BAS$_OPERACAOCREDOR_E',
                         'BAS$_PLANO_ORCAMENTARIO_E',
                         'BAS$_RECURSO_VINCULADO_E',
                         'BAS$_TIPO_PLANO_CONTABIL_E'))

ORDER BY table_name;
