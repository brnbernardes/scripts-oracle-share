-- Constraint columns:
SELECT c.owner,
       c.table_name,
       c.constraint_name,
       c.constraint_type,
       '(' || listagg(cc.column_name, ', ') within GROUP(ORDER BY position) || ');' cols,
       'ALTER TABLE ' || c.owner || '.' || c.table_name || ' DISABLE CONSTRAINT ' || c.constraint_name || ';' "DISABLE", 
       'ALTER TABLE ' || c.owner || '.' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name || ';' "ENABLE"
  FROM dba_cons_columns cc
INNER JOIN dba_constraints c
ON c.owner = cc.owner
AND c.constraint_name = cc.constraint_name
 WHERE c.owner = 'ERP'
 AND c.constraint = '&CONSTRAINT_FK_OR_PK'
 --AND c.constraint_table = '&TABLE'
 GROUP BY c.owner, c.table_name, c.constraint_name, constraint_type;


-- FKs da PK ou TABLE
WITH fks AS 
(SELECT c.owner,
       c.table_name,
       c.constraint_name fk_name,
       '(' || listagg(cc.column_name, ', ') within GROUP(ORDER BY cc.position) || ');' fk_cols,
       'ALTER TABLE ' || c.owner || '.' || c.table_name || ' DISABLE CONSTRAINT ' || c.constraint_name || ';' "DISABLE",
       'ALTER TABLE ' || c.owner || '.' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name || ';' "ENABLE",
       c.validated,
       c.status
  FROM dba_cons_columns cc
INNER JOIN dba_constraints c
ON c.owner = cc.owner
AND c.constraint_name = cc.constraint_name
INNER JOIN dbA_constraints cp
ON c.r_constraint_name = cp.constraint_name
AND c.r_owner = cp.owner
INNER JOIN dba_cons_columns ccp 
ON ccp.owner = cp.owner
AND ccp.constraint_name = cp.constraint_name
 WHERE c.owner = 'ERP'
 AND cp.constraint_name = '&PK'
 --AND cp.table_namename = '&TABLE_PK'
 GROUP BY c.owner, c.table_name, c.constraint_name, c.validated, c.status)
SELECT * FROM fks;


--Table Columns
SELECT table_name,
       listagg(lower(column_name), ', ') within GROUP(ORDER BY column_id) cols
  FROM dba_tab_columns
 WHERE table_name   IN ('BAS$_PROGRAMA_E', 'BAS$_PROGRAMA_VINCULO_E', 'BAS$_PROGRAMA_CHAVEPRIMARIA_E')
 GROUP BY table_name;


--Modify constraint novalidate
SELECT 'ALTER TABLE ' || c.table_name || ' add constraint ' ||
       c.constraint_name || ' FOREIGN KEY (' ||
       (select listagg(column_name, ',') within group(order by position)
          from dba_cons_columns
         where owner = c.owner
           and constraint_name = c.constraint_name) || ') REFERENCES ' ||
       (select distinct table_name
          from all_constraints
         where owner = c.r_owner
           and constraint_name = c.r_constraint_name) || ' (' ||
       (select listagg(column_name, ',') within group(order by position)
          from dba_cons_columns
         where owner = c.owner
           and constraint_name = c.r_constraint_name) ||
       ') deferrable enable novalidate;' "ALTER_TABLE"
  FROM dba_constraints c
 WHERE c.owner = 'ERP'
   AND c.constraint_type = 'R'
   AND c.table_name in ('CTB$_EMPENHO_PARCELA_OP_E') --TABLE
   AND c.constraint_name = 'CTB$_EMPPARCLIQOP_EMPPARC_FK' --FK
   AND c.R_CONSTRAINT_NAME IS NOT NULL;

-- FK: Foreign Key
col fk_constraint_table for a30
col fk_constraint_name for a35
col fk_delete_rule for a15
col pk_constraint_name for a30
col pk_constraint_table for a30
col pk_delete_rule for a15
col table_name for a30
col constraint_name for a30
SELECT r.table_name fk_constraint_table,
       r.constraint_name fk_constraint_name,     
       r.delete_rule fk_delete_rule,
       r.status fk_status,
       p.table_name pk_constraint_table,
       r.r_constraint_name pk_constraint_name,   
       p.status pk_status
  FROM dba_constraints r
 INNER JOIN dba_constraints p
 ON r.r_owner = p.owner
 AND r.r_constraint_name = p.constraint_name
 WHERE r.owner = 'ERP'
   AND r.constraint_name = '&FK';
 

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Gerar DDL FKs FROM PK
BEGIN
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.session_transform,'CONSTRAINTS_AS_ALTER', true);
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.session_transform,'REF_CONSTRAINTS', TRUE);
DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT dbms_lob.substr(dbms_metadata.get_ddl('REF_CONSTRAINT', r.constraint_name), 4000, 1) DDL_FK
  FROM dba_constraints r
 INNER JOIN dba_constraints p
 ON r.r_owner = p.owner
 AND r.r_constraint_name = p.constraint_name
 WHERE r.owner = 'ERP'
   AND p.constraint_name = 'CTB$_DIV_FUND_UK';