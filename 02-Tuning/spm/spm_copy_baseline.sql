/*
 ORIGEM 
*/

-- 1) Localizar plano 
SELECT DISTINCT plan_hash_value FROM v$sql WHERE sql_id = 'a83r7q0pmpw4h';


--2) Criar baseline
DECLARE
  ret               BINARY_INTEGER;
  l_sql_id          VARCHAR2(13);
  l_plan_hash_value NUMBER;
  l_fixed           VARCHAR2(3);
  l_enabled         VARCHAR2(3);
BEGIN
  l_sql_id          := 'a83r7q0pmpw4h';
  l_plan_hash_value := to_number('2812354923');
  l_fixed           := 'YES';
  l_enabled         := 'YES';
  ret               := dbms_spm.load_plans_from_cursor_cache(sql_id => l_sql_id,
                                                             plan_hash_value => l_plan_hash_value,
                                                             fixed => l_fixed,
                                                             enabled => l_enabled);
END;
/

/*
--2) criar baseline pra todos plan_hashs
declare
    v_ret number;
begin
    v_ret := dbms_spm.load_plans_from_cursor_cache(sql_id=> 'a83r7q0pmpw4h');
end;
/
*/

--3) Coletar informações da Baseline criada para passo 5
SELECT plan_name, sql_handle  FROM dba_sql_plan_baselines;


--4) Criar tabela de preparação (SYS)
BEGIN
  DBMS_SPM.CREATE_STGTAB_BASELINE(
  table_name      => 'SPM_STAGETAB',
  table_owner     => 'ERP',
  tablespace_name => 'USERS');
END;
/

--5) Inserir baseline na tabela
DECLARE
  my_plans NUMBER;
BEGIN
  my_plans := dbms_spm.pack_stgtab_baseline(table_name => 'SPM_STAGETAB',
                                            enabled => 'yes',
                                            table_owner => 'ERP',
                                            plan_name => 'SQL_PLAN_...',
                                            sql_handle => 'SQL_...');
END;
/

--6) Exportar
expdp '"/ as sysdba"' directory=DATAPUMP dumpfile=spm_stagetab.dmp logfile=spm_stagetab.log  TABLES=ERP.SPM_STAGETAB


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

/*
 DESTINO 
*/

--1) Importar
impdp '"/ as sysdba"' directory=DATAPUMP dumpfile=spm_stagetab.dmp logfile=spm_stagetab.log 


--2) Descompactar baseline
DECLARE
  l_plans_unpacked PLS_INTEGER;
BEGIN
  l_plans_unpacked := dbms_spm.unpack_stgtab_baseline(table_name => 'SPM_STAGETAB',
                                                      table_owner => 'ERP');

  dbms_output.put_line('Plans Unpacked: ' || l_plans_unpacked);
END;
/

--3) Verificar baseline e definir como plano fixo
SELECT sql_handle, plan_name, enabled, accepted, fixed, origin FROM dba_sql_plan_baselines;

/*
A saída anterior com FIXED = N
mostra que a linha de base foi importada na instância de destino, mas não foi corrigida. 
Execute a consulta a seguir para corrigir a linha de base e permitir que o otimizador escolha apenas este plano.
*/

DECLARE
  l_plans_altered PLS_INTEGER;
BEGIN
  l_plans_altered := dbms_spm.alter_sql_plan_baseline(sql_handle => 'SQL_59608cf93db347bd',
                                                      plan_name => 'SQL_PLAN_5ks4cz4yv6jxx85810f03',
                                                      attribute_name => 'fixed',
                                                      attribute_value => 'YES');

  dbms_output.put_line('Plans Altered: ' || l_plans_altered);
END;
/

-- verficicar novamente
SELECT sql_handle, plan_name, enabled, accepted, fixed, origin FROM dba_sql_plan_baselines;


--4) Executar a consulta novamente (via app) e validar se está atribuindo a base line
SELECT sql_plan_baseline FROM v$sql WHERE sql_id = 'a83r7q0pmpw4h';
