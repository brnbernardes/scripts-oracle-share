-- Verificação de auditoria ativa sobre a tabela
SELECT t.owner, trigger_name, table_name, created, last_ddl_time, TIMESTAMP, t.status trigger_status, o.status object_status
  FROM dba_objects o
 INNER JOIN dba_triggers t
    ON o.owner = t.owner
   AND o.object_name = t.trigger_name
 WHERE table_name = '&TABLE'
AND trigger_name like 'ADB$%';  


-- Tabela
SELECT data, evento, conteudo, chave, nomeusuario
  FROM erp_adb.adb$_audit_e a
 WHERE tabela = 'BAS$_STCADASTRAL_E'
   AND chave = 'CODIGO_CLIENTE=1;SITUACAO=W'
   AND conteudo LIKE 'CONFIRMADO%'
   AND codigo_cliente = 1
 ORDER BY data;

--Tabela: cumulativo por evento
SELECT codigo_cliente, evento, MIN(DATA),  MAX(data)
  FROM erp_adb.adb$_audit_e a
 WHERE tabela = 'GRP_TRI_AVERBACAO_E'
 AND codigo_cliente = 42
GROUP BY codigo_cliente, evento;


-- Auditoria DDL
SELECT * FROM dba_triggers WHERE triggering_event LIKE 'DDL%';
SELECT sysdate, a.* FROM erp_adb.adb$_audit_ddl_e A WHERE data_operacao >= '25/03/2020' ORDER BY data_operacao DESC;

-- User
  SELECT session_id, usuario, osuser, session_logon, program, machine, user_session_id
    FROM erp_adb.adb$_user_session_e
  WHERE session_logon >= '25/03/2020'
    AND usuario NOT IN ('ERP_ADB', 'SYS', 'APEX_050100', 'ORDS_METADATA')
    AND osuser not in ('oracle', 'thema')
    AND usuario = 'ERP'
  ORDER BY session_logon DESC;

--> Auditoria DDL + Sessions
SELECT sequencia,
       data_operacao,
       operacao,
       tipo_objeto,
       nome_objeto,
       status,
       failures,
       session_id,       
       nomeusuario,
       (SELECT osuser FROM erp_adb.adb$_user_session_e WHERE user_session_id = a.session_id ) AS os_user
  FROM erp_adb.adb$_audit_ddl_e a
 WHERE data_operacao >= '14/01/2025'
 ORDER BY data_operacao DESC;


-- Restore 
SELECT dbms_lob.substr('update CTB$_LIQUIDACAO_E ' || ' set ' ||
      REPLACE(
      regexp_replace(
        REPLACE(REPLACE(REPLACE(conteudo,chr(10),null),chr(13), null),'[', '='''), 
        '\-\-\>([0-9]|[A-Z]|[a-z]|[,]|[/])*]', ''', '), '-->{vazio}]', ''',')
      || ' WHERE ' || REPLACE(REPLACE(chave, 'chave=', ''), ';', ' and ') || ';',4000,1) AS comando
      --,conteudo
 FROM erp_adb.adb$_audit_e
WHERE tabela = 'CTB$_LIQUIDACAO_E'
  AND data >= to_date('15/09/2023 12:50:00', 'dd/mm/yyyy hh24:mi:ss')
  AND nomeusuario = 'DIRLENERODRIGUES'
  AND evento = 'UPDATING'
  AND conteudo LIKE '%7597/2023%';

-- Merge
merge into LIQUIDACAO t
using (
        select nomeUsuario, evento, chave
             , regexp_substr(chave,'\d{2}') as codigo_cliente
             , regexp_substr(chave,'(CODIGO_ADMINISTRACAO=)(\d*)',1,1,'i',2) as codigo_administracao
             , regexp_substr(chave,'(EXERCICIO=)(\d*)',1,1,'i',2) as exercicio
             , regexp_substr(chave,'(NUMERO_LIQUIDACAO=)(.*)',1,1,'i',2) as numero_liquidacao
             , conteudo
             , cast(regexp_substr(conteudo,'INTEGRACAOEXTERNA\[([^\-]+)\-\-\>',1,1,'i',1) as varchar2(100)) as integracaoExternaOriginal
             , cast(regexp_substr(conteudo,'DESCRICAOEXTERNA\[([^\-]+)\-\-\>',1,1,'i',1) as varchar2(100)) as descricaoExternaOriginal
             , cast(regexp_substr(conteudo,'DATAINTEGRACAOEXTERNA\[([^\-]+)\-\-\>',1,1,'i',1) as varchar2(100)) as dataIntegracaoExternaOriginal
         from GRP_ADB_AUDIT 
        where cliente=46
          and nomeUsuario = 'DIRLENERODRIGUES'
          and tabela = 'CTB$_LIQUIDACAO_E'
          and data between to_date('15/09/2023 12:56', 'DD/MM/RRRR HH24:MI') and to_date('15/09/2023 17:00', 'DD/MM/RRRR HH24:MI')
          and evento='UPDATING'
          ) a
on (t.CODIGO_CLIENTE=a.CODIGO_CLIENTE 
    and t.CODIGO_ADMINISTRACAO=a.CODIGO_ADMINISTRACAO 
    and t.EXERCICIO=a.EXERCICIO 
    and t.NUMERO_LIQUIDACAO=a.NUMERO_LIQUIDACAO)
when matched then
update set t.integracaoExterna = case a.integracaoExternaOriginal when null then null else a.integracaoExternaOriginal end
         , t.descricaoExterna = case a.descricaoExternaOriginal when null then null else a.descricaoExternaOriginal end
         , t.dataIntegracaoExterna = case a.dataIntegracaoExternaOriginal when null then null else a.dataIntegracaoExternaOriginal end;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Verificar: Alteração de objetos na data específica
SET pages 9999
col data_operacao for a24
col data_primeira_operacao for a24
col data_ultima_operacao for a24
col tipo_objeto for a11
col usuario for a15
col program for a15
col machine for a15
col osuser for a15
col osuser for a15
SELECT operacao,
       usuario,
       program,
       machine,
       osuser,
       MIN(data_operacao) data_primeira_operacao,
       max(data_operacao) data_ultima_operacao,
       COUNT(1) quantidade_operacao
  FROM erp.adb$_audit_ddl_e a
 INNER JOIN erp.adb$_user_session_e s
    ON a.session_id = s.user_session_id
 WHERE TRUNC(data_operacao) = '14/01/2025'
GROUP BY operacao,
       usuario,
       program,
       machine,
       osuser;

SELECT data_operacao,
       operacao,
       nome_objeto,
       tipo_objeto,
       usuario,
       program,
       machine,
       osuser
  FROM erp.adb$_audit_ddl_e a
 INNER JOIN erp.adb$_user_session_e s
    ON a.session_id = s.user_session_id
 WHERE data_operacao >= '14/01/2025';
       