
-- SPM: Load Plans
declare
    v_ret number;
begin
    v_ret := dbms_spm.load_plans_from_cursor_cache(attribute_name => , attribute_value => , fixed => , enabled => )
end;
/

declare
    v_ret number;
begin
    v_ret := dbms_spm.load_plans_from_cursor_cache(sql_id => '7bg06s89k0x27', plan_hash_value =>'3013918973');
end;
/



-- SPM: Plans
select  sql_text, sql_handle, plan_name, optimizer_cost as cost, enabled, fixed from  dba_sql_plan_baselines b;
select b.* from  dba_sql_plan_baselines b;

/*
Alterando as linhas de base do plano
A ALTER_SQL_PLAN_BASELINE fun��o permite que os seguintes atributos de um plano espec�fico ou de todos os planos dentro de uma linha de base sejam alterados:
 - enabled(SIM/N�O): Se SIM, o plano estar� dispon�vel para o otimizador se tamb�m estiver marcado como aceito.
 - fixed(SIM/N�O): Se SIM, a linha de base do plano SQL n�o evoluir� ao longo do tempo. Planos fixos s�o usados ??preferencialmente em vez de planos n�o fixos.
 - autopurge(SIM/N�O): Se SIM, a linha de base do plano SQL ser� eliminada automaticamente se n�o for usada por um per�odo de tempo.
 - plan_name: Usado para alterar o nome do plano SQL, com no m�ximo 30 caracteres.
 - description: Usado para alterar a descri��o do plano SQL, com no m�ximo 30 caracteres.
*/

-- SPM: Enabled
declare
    v_ret number;
begin
    v_ret := dbms_spm.alter_sql_plan_baseline(sql_handle => '&SQL_HANDLE',
               plan_name => '&SQL_PLAN_BASELINE',
               attribute_name => 'ENABLED',
               attribute_value => 'YES');
end;
/

-- SPM: Fixed
declare
    v_ret number;
begin
    v_ret := DBMS_SPM.ALTER_SQL_PLAN_BASELINE (
   sql_handle      => 'SQL_f047937070c9c00e',
   plan_name       => 'SQL_PLAN_g0jwmf1scmh0f7965d04c',
   attribute_name  => 'FIXED',
   attribute_value => 'YES');
end;
/

-- SPM: Drop
declare
    v_ret number;
begin
 v_ret:= dbms_spm.drop_sql_plan_baseline(sql_handle => 'SQL_f047937070c9c00e' , plan_name => 'SQL_PLAN_g0jwmf1scmh0f4fc2b6c0' );
END;
/

-- SPM: Explain
select *
  from table(dbms_xplan.display_sql_plan_baseline(sql_handle => 'SQL_f047937070c9c00e',
                                                  format     => 'advanced'));