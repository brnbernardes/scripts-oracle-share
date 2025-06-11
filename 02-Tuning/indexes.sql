/*
 * SELETIVIDADE: é o item mais importante para a criação de um índice, pois é com ele que conseguimos deixar um índice realmente efetivo. Mas o que é seletividade?
 *
 * Seletividade nada mais é que um determinado campo de uma tabela contenha uma quantidade muito pequena ou nenhuma repetição de registros, ou seja, quanto menos se repetirem 
 * os dados de uma coluna, mais seletiva ela se torna.
 *
 * Com a execução do script acima, conseguimos saber a seletividade das colunas na criação do índice através do campo PCT_SELETIVIDADE. 
 *  1) Caso este campo retorne um valor INFERIOR a 15%, é porque o campo ou um conjunto de campos são seletivos. 
 *  2) Caso este campo seja SUPERIOR a 15%, não é recomendável a criação do índice pelo(s) campo(s) informado(s).
 * Importante: Este percentual não é uma regra ou fórmula, pois pode variar em alguns casos, mas é uma margem de segurança baseando-se na experiência de análise de perfomance de querys.
*/


SELECT MIN(x) menor_grupo,
       MAX(x) maior_grupo,
       SUM(x) total_linhas,
       100 * AVG(x) / SUM(x) pct_seletividade
  FROM (SELECT COUNT(*) x
          FROM &owner_tabela /*Tabela onde será criado o índice*/
         GROUP BY &colunas_separadas_por_virgula); /*Colunas a serem indexadas */



/*
 * ORDEM: também um item muito importante para performance
 * É recomendado, sempre, colocar as colunas mais seletivas da esquerda para direita, onde esquerda é mais seletivo e direita menos seletivo.
*/

/*
 * PARTICIONAMENTO: 
 * Caso a tabela seja particionada, é extremamente recomendado, em todos os índices LOCAL ter a chave de partição entre as colunas indexadas, pois caso contrário, o índice não será efetivo.
*/


/*
 * FUNTIONS: 
 * Não se deve utilizar função nos filtros que contém índice sem função ou chave de partição, caso contrário os índices não serão utilizados. 
 * Para estes casos, deverá ser criado índice de função.
*/


