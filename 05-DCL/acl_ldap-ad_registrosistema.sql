-- Registro de sistema: Config Wallet
SELECT r.nome_chave, r.hierarquialower,rc.nome_conteudo, rc.tipo_conteudo, rc.conteudo 
  FROM erp.bas$_registro_e r
 INNER JOIN erp.bas$_registro_conteudo_e rc
    ON r.codigo_cliente = rc.codigo_cliente
   AND r.numero_chave = rc.numero_chave
WHERE hierarquialower LIKE '%\oracle'
AND rc.nome_conteudo LIKE 'wallet%';

-- Registro de Sistema: Config LDAP
SELECT rc.numero_chave, rc.numero_conteudo, r.nome_chave, r.hierarquialower,rc.nome_conteudo, rc.tipo_conteudo, rc.conteudo 
  FROM erp.bas$_registro_e r
 INNER JOIN erp.bas$_registro_conteudo_e rc
    ON r.codigo_cliente = rc.codigo_cliente
   AND r.numero_chave = rc.numero_chave
WHERE hierarquialower LIKE '%\sistema\login%'
AND r.nome_chave = 'LDAP';

-- Veriricar liberações por ACL
SELECT a.acl,
       a.host,
       a.lower_port,
       a.upper_port,
       b.principal,
       b.privilege,
       b.is_grant,
       b.start_date,
       b.end_date,
       sysdate
  FROM dba_network_acls a
  JOIN dba_network_acl_privileges b
    ON a.acl = b.acl
WHERE a.acl like '%.xml'
 ORDER BY a.acl, a.host, a.lower_port, a.upper_port;

-- Configuração de Usuario
SELECT cd_usuario,
       ds_usuario,
       habilitado,
       cadastrogeral,
       autenticacaointerna,
       autenticacaoldap,
       autenticacaocertificado,
       tipo,
       cd_categoria,
       tipo_categoria,
       email,
       datacriacao,
       dataalteracao
  FROM erp.bas$_usuario_e
 WHERE ds_usuario LIKE lower('&usuario');

-- Criar objeto de teste no owner ERP para não existir necessidade de mudar de user devido a ACL
CREATE OR REPLACE PROCEDURE ERP.BAS$_TESTE_AD_LDAP_P AS
  l_retval        PLS_INTEGER;
  l_session       DBMS_LDAP.session;

  l_ldap_host VARCHAR2(100) := 'tj.rj.gov.br';
  l_ldap_port VARCHAR2(100) := '389';


  l_ldap_user   VARCHAR2(100) := 'usr_thema';
  l_ldap_passwd VARCHAR2(100) := '&%21rpwtH9-1';

 -- l_wallet_file   VARCHAR2(100) := 'file:/u01/app/oracle/....';
 -- l_wallet_passwd VARCHAR2(100) := 'senha...';
BEGIN
  dbms_ldap.use_exception := true;
  l_session               := DBMS_LDAP.init(hostname => l_ldap_host,
                                            portnum  => l_ldap_port);

 /* l_retval := DBMS_LDAP.open_ssl(ld              => l_session,
                                 sslwrl          => l_wallet_file,
                                 sslwalletpasswd => l_wallet_passwd,
                                 sslauth         => 2);
*/
  l_retval := DBMS_LDAP.simple_bind_s(ld     => l_session,
                                      dn     => l_ldap_user,
                                      passwd => l_ldap_passwd);

  dbms_output.put_line('OK');
END;
/

BEGIN
  ERP.BAS$_TESTE_AD_LDAP_P;
END;
/


