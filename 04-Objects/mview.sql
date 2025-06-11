Vantagens de ATOMIC_REFRESH => FLASE
- Muito menos rota��es de redologs e gera��o de archives
- O processo de atualiza��o completo � muito r�pido em compara��o ao processo com ATOMIC_REFRESH => TRUE

Desvantagens de ATOMIC_REFRESH => FLASE
 - Indisponibilidade de dados durante o processo de atualização, 
   o que pode ser inaceitável para aplicativos e usuários empresariais.

EXEC DBMS_MVIEW.REFRESH('MVIEW_NAME', METHOD => 'C', ATOMIC_REFRESH => FALSE);