Vantagens de ATOMIC_REFRESH => FLASE
- Muito menos rotações de redologs e geração de archives
- O processo de atualização completo é muito rápido em comparação ao processo com ATOMIC_REFRESH => TRUE

Desvantagens de ATOMIC_REFRESH => FLASE
 - Indisponibilidade de dados durante o processo de atualizaÃ§Ã£o, 
   o que pode ser inaceitÃ¡vel para aplicativos e usuÃ¡rios empresariais.

EXEC DBMS_MVIEW.REFRESH('MVIEW_NAME', METHOD => 'C', ATOMIC_REFRESH => FALSE);