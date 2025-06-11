SET feed OFF
COL MODULE FOR a50
SELECT x.*, count(1) total 
FROM (
SELECT  inst_id,
        case
         when username is null and type like 'BACKGROUND' then
          'ORACLE'
         else
          username
       end username,       
       case when client_identifier is not null then 'USUARIO_DO_GRP' else 'POOL' END client_identifier_type, 
       module,
       status
  FROM gv$session s
  WHERE s.username LIKE 'ACESSODIRETO'
 ) x
GROUP BY x.inst_id, x.username, x.module, x.status, x.client_identifier_type
ORDER BY inst_id, total desc; 

prompt ***
SELECT username, module, machine, COUNT(1) quantidade_sess
  FROM gv$session s 
 WHERE username IN ('ACESSODIRETO', 'NFSE')
 --AND MODULE = 'CMS_AUTORIZACAO'
GROUP BY username, module, machine
ORDER BY 1,2,3 ;

prompt ***

SELECT 'PROCESS' parameter,  SUM(1) total  FROM v$process s
UNION ALL
SELECT 'SESSION',  SUM(1) total  FROM v$session s
-- WHERE s.username LIKE 'ACESSODIRETO';
