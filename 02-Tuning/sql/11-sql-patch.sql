----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create SQL Patch add gather_plan_statistics
DECLARE
  l_patch_name VARCHAR2(100);
  l_sqlid      VARCHAR2(32) := '2av63umk7zzt6';
  vname        VARCHAR2(32) := 'patch_' || l_sqlid || '_plan_stats';
BEGIN

  l_patch_name := sys.dbms_sqldiag.create_sql_patch(sql_id => l_sqlid,
                                                    hint_text => 'gather_plan_statistics',
                                                    NAME => vname,
                                                    category => 'DEFAULT');

  dbms_output.put_line('SQL Patch: ' || l_patch_name);
END;
/

-- Drop SQL Patch
BEGIN
  sys.dbms_sqldiag.drop_sql_patch(NAME => 'patch_'||&sq_lid||'_plan_stats');
END;
/


----------------------------------------------------------------------------------------------------------------------------------------------------------
--NOPARALLEL

DECLARE
  l_patch_name VARCHAR2(100);
  l_sqlid      VARCHAR2(32) := '9jacznfddh1au';
  vname        VARCHAR2(32) := 'patch_' || l_sqlid;
BEGIN

  l_patch_name := sys.dbms_sqldiag.create_sql_patch(sql_id => l_sqlid,
                                                    hint_text => 'NOPARALLEL)',
                                                    NAME => vname,
                                                    category => 'DEFAULT');

  dbms_output.put_line('SQL Patch: ' || l_patch_name);
END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------
--Para utilização de índice

DECLARE
  l_patch_name VARCHAR2(100);
  l_sqlid      VARCHAR2(32) := '9jacznfddh1au';
  vname        VARCHAR2(32) := 'patch_' || l_sqlid;
BEGIN

  l_patch_name := sys.dbms_sqldiag.create_sql_patch(sql_id => l_sqlid,
                                                    hint_text => 'INDEX(@"SEL$B7274CD5" "BAS$_CADASTROGERAL_E"@"SEL$2" "BAS$_CADASTROGERAL_COMP_CFPCNPJ_I2")',
                                                    NAME => vname,
                                                    category => 'DEFAULT');

  dbms_output.put_line('SQL Patch: ' || l_patch_name);
END;
/


----------------------------------------------------------------------------------------------------------------------------------------------------------
--Para utilização do "Outline Data"

DECLARE
  l_patch_name VARCHAR2(100);
  l_sqlid      VARCHAR2(32) := '9jacznfddh1au';
  vname        VARCHAR2(32) := 'patch_' || l_sqlid;
BEGIN

  l_patch_name := sys.dbms_sqldiag.create_sql_patch(sql_id => l_sqlid,
                                                    hint_text => q'[BEGIN_OUTLINE_DATA
IGNORE_OPTIM_EMBEDDED_HINTS
OPTIMIZER_FEATURES_ENABLE('10.2.0.5')
DB_VERSION('19.1.0')
ALL_ROWS
OUTLINE_LEAF(@"SEL$B7274CD5")
UNNEST(@"SEL$07BDC5B4")
OUTLINE(@"SEL$F5BB74E1")
MERGE(@"SEL$2" >"SEL$1")
OUTLINE(@"SEL$07BDC5B4")
MERGE(@"SEL$4" >"SEL$3")
OUTLINE(@"SEL$1")
OUTLINE(@"SEL$2")
OUTLINE(@"SEL$3")
OUTLINE(@"SEL$4")
INDEX(@"SEL$B7274CD5" "BAS$_CADASTROGERAL_E"@"SEL$2" "BAS$_CADASTROGERAL_COMP_CFPCNPJ_I2")
INDEX(@"SEL$B7274CD5" "BAS$_STCADASTRAL_E"@"SEL$4" ("BAS$_STCADASTRAL_E"."CODIGO_CLIENTE" "BAS$_STCADASTRAL_E"."ATIVO"
        "BAS$_STCADASTRAL_E"."MULTIFINALITARIO" "BAS$_STCADASTRAL_E"."SITUACAO"))
LEADING(@"SEL$B7274CD5" "BAS$_CADASTROGERAL_E"@"SEL$2" "BAS$_STCADASTRAL_E"@"SEL$4")
USE_NL(@"SEL$B7274CD5" "BAS$_STCADASTRAL_E"@"SEL$4")
END_OUTLINE_DATA
]',
                                                    NAME => vname,
                                                    category => 'DEFAULT');

  dbms_output.put_line('SQL Patch: ' || l_patch_name);
END;
/


---------------------------------------------------------------------------------------------------------------------------------------------------------------------
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  3jf05y3k5vdm3, child number 0
-------------------------------------
SELECT /*DBA_THEMA: Teste 01*/  grp_bas_cadastrogeral.inscricao,
grp_bas_cadastrogeral.email   FROM grp_bas_cadastrogeral  WHERE
grp_bas_cadastrogeral.cpfcnpj = :"SYS_B_0"        AND rownum <
:"SYS_B_1"

Plan hash value: 1931038064

---------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name                               | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |                                    |      1 |        |       |     3 (100)|          |      1 |00:00:00.01 |       4 |
|*  1 |  COUNT STOPKEY     |                                    |      1 |        |       |            |          |      1 |00:00:00.01 |       4 |
|   2 |   NESTED LOOPS SEMI|                                    |      1 |      1 |    37 |     3   (0)| 00:00:01 |      1 |00:00:00.01 |       4 |
|*  3 |    INDEX RANGE SCAN| BAS$_CADASTROGERAL_COMP_CFPCNPJ_I2 |      1 |      1 |    28 |     3   (0)| 00:00:01 |      1 |00:00:00.01 |       3 |
|*  4 |    INDEX RANGE SCAN| BAS$_STCADASTRAL_AT_ST_MU_IDX      |      1 |      2 |    18 |     0   (0)|          |      1 |00:00:00.01 |       1 |
---------------------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$B7274CD5
   3 - SEL$B7274CD5 / BAS$_CADASTROGERAL_E@SEL$2
   4 - SEL$B7274CD5 / BAS$_STCADASTRAL_E@SEL$4

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('10.2.0.5')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$B7274CD5")
      UNNEST(@"SEL$07BDC5B4")
      OUTLINE(@"SEL$F5BB74E1")
      MERGE(@"SEL$2" >"SEL$1")
      OUTLINE(@"SEL$07BDC5B4")
      MERGE(@"SEL$4" >"SEL$3")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      OUTLINE(@"SEL$3")
      OUTLINE(@"SEL$4")
      INDEX(@"SEL$B7274CD5" "BAS$_CADASTROGERAL_E"@"SEL$2" "BAS$_CADASTROGERAL_COMP_CFPCNPJ_I2")
      INDEX(@"SEL$B7274CD5" "BAS$_STCADASTRAL_E"@"SEL$4" ("BAS$_STCADASTRAL_E"."CODIGO_CLIENTE" "BAS$_STCADASTRAL_E"."ATIVO"
              "BAS$_STCADASTRAL_E"."MULTIFINALITARIO" "BAS$_STCADASTRAL_E"."SITUACAO"))
      LEADING(@"SEL$B7274CD5" "BAS$_CADASTROGERAL_E"@"SEL$2" "BAS$_STCADASTRAL_E"@"SEL$4")
      USE_NL(@"SEL$B7274CD5" "BAS$_STCADASTRAL_E"@"SEL$4")
      END_OUTLINE_DATA
  */

Peeked Binds (identified by position):
--------------------------------------

   2 - :2 (NUMBER): 2

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM<:SYS_B_1)
   3 - access("BAS$_CADASTROGERAL_E"."SYS_NC00095$"=:SYS_B_0 AND "CODIGO_CLIENTE"=TO_NUMBER(SYS_CONTEXT('BAS$','CLIENTE')))
   4 - access("CODIGO_CLIENTE"=TO_NUMBER(SYS_CONTEXT('BAS$','CLIENTE')) AND "ATIVO"='S' AND "MULTIFINALITARIO"='S' AND
              "SITUACAO"="BAS$_CADASTROGERAL_E"."STCADASTRAL")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "INSCRICAO"[NUMBER,22], "EMAIL"[VARCHAR2,320]
   2 - "INSCRICAO"[NUMBER,22], "EMAIL"[VARCHAR2,320]
   3 - "INSCRICAO"[NUMBER,22], "BAS$_CADASTROGERAL_E"."STCADASTRAL"[VARCHAR2,1], "EMAIL"[VARCHAR2,320]

Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 2
---------------------------------------------------------------------------

   0 -  STATEMENT
           -  IGNORE_OPTIM_EMBEDDED_HINTS
           -  OPTIMIZER_FEATURES_ENABLE('10.2.0.5')

Note
-----
   - SQL profile SYS_SQLPROF_0196f33365f90000 used for this statement
