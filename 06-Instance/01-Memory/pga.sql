--PGA Target: Advice
SELECT round(pga_target_for_estimate / 1024 / 1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
  FROM v$pga_target_advice;



--> Entendendo o papel da PGA nas sess�es no banco de dados Oracle

--> Ambiente

	Oracle Linux 8
	SGBD Oracle 19c
	Enterprise Edition (Valido para qualquer edition)
	Single Instance (Valido para RAC)
	NonCDB (Valido para CDB)
	
	
--> Objetivo do video
	
	- Voc� vai entender o que � a PGA, como ele afeta o desempenho das sess�es e por que � t�o importante para a administra��o do banco de dados Oracle.
	
	
--> O que � a PGA?  

	- Defini��o: A PGA � uma �rea de mem�ria dedicada a cada sess�o no Oracle. Ela � usada para armazenar informa��es espec�ficas da sess�o, como vari�veis de bind, informa��es de cursores e o espa�o de mem�ria para opera��es de sorting e joins.
	- Componentes Importantes da PGA: Dentro da PGA, temos componentes como o Private SQL Area e o Sort Area, que s�o essenciais para a execu��o de consultas e manipula��o de dados.
	- Rela��o com a SGA: � importante saber que a PGA � diferente da SGA (System Global Area), que � compartilhado entre todas as sess�es. A PGA, por sua vez, � dedicado exclusivamente a cada sess�o.
	
	
--> Como a PGA Afeta o Desempenho das Sess�es? 

	- Uso da PGA nas Sess�es: Cada vez que uma sess�o � iniciada, o Oracle aloca uma �rea da PGA para ela e libera quando a sess�o desconecta. A quantidade de mem�ria dispon�vel na PGA pode influenciar diretamente o desempenho dessa sess�o.
	- Exemplo Pr�tico: Se uma sess�o consome muita PGA, por exemplo, ao realizar um join complexo ou uma ordena��o de dados muito grande, isso pode impactar o desempenho, fazendo com que o Oracle precise recorrer � troca de mem�ria com o disco usando a tablespace temporaria, o que � muito mais lento.
	- Quando a PGA � um Problema: Se a PGA estiver configurado com um valor muito baixo, voc� pode ver muitas opera��es de disco, o que vai gerar um impacto negativo no desempenho.


--> Demonstra��o pr�tica 

	-- Simular varias conex�es

	-- Como monitorar o uso da PGA
	
		- Visualizar uso atual por sess�o 
			set linesize 500
			set pagesize 1000
			col username format a10
			col osuser format a15
			col spid format a5
			--col service_name format a10
			--col module format a10
			--col machine format a10
			--col logon_time format a10
			col pga_used_mem_mb format 99990.00
			col pga_alloc_mem_mb format 99990.00
			col pga_freeable_mem_mb format 99990.00
			col pga_max_mem_mb format 99990.00
			SELECT NVL(s.username, '(oracle)') AS username
				--,s.osuser
				,s.sid
				,s.serial#
				,p.spid
				,ROUND(p.pga_used_mem/1024/1024,2) AS pga_used_mem_mb
				,ROUND(p.pga_alloc_mem/1024/1024,2) AS pga_alloc_mem_mb
				,ROUND(p.pga_freeable_mem/1024/1024,2) AS pga_freeable_mem_mb
				,ROUND(p.pga_max_mem/1024/1024,2) AS pga_max_mem_mb
				,s.status
				--,s.service_name
				--,s.module
				--,s.machine
				--,s.program
				--,TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
				--,s.last_call_et AS last_call_et_secs
			FROM   v$session s, v$process p
			WHERE  s.paddr = p.addr
			AND s.type != 'BACKGROUND'
			ORDER BY s.username, s.osuser;
			
			--> PGA_USED_MEM: Mem�ria PGA atualmente usada pelo processo (em bytes)
			--> PGA_ALLOC_MEM: Mem�ria PGA atualmente alocada pelo processo (incluindo mem�ria PGA livre ainda n�o liberada para o sistema operacional pelo processo do servidor (em bytes)
			--> PGA_FREEABLE_MEM: Mem�ria PGA alocada que pode ser liberada (em bytes)
			--> PGA_MAX_MEM: Mem�ria PGA m�xima j� alocada pelo processo (em bytes)
		
		- Total de PGA usada no momento
		
			SELECT name.name,sum(stat.value)/1024/1024 PGA_MB
			FROM v$statname name, v$sesstat stat
			WHERE name.statistic#=stat.statistic#
			AND name.name LIKE '%pga%'
			GROUP BY name.name;
			
		- Eliminando sess�o que esta consumindo muita PGA 
		
			set linesize 200;
			set pagesize 10000;
			SELECT 'alter system disconnect session ''' || sid|| ',' ||serial# || ',@'||inst_id||''' immediate;'
			FROM gv$session 
			WHERE type != 'BACKGROUND';
		
		
	- Ajustando o Tamanho do PGA
	
		- Visualizar configura��o atual 
		
			show parameters pga_aggregate_target;
			show parameters pga_aggregate_limit;
			
		- Dica para configura��o do tamanho da PGA 
		
			SELECT &max_connected_sessions*(2048576+p1.value+p2.value)/(1024*1024) as you_need_pga_mb 
			FROM v$parameter p1, v$parameter p2
			WHERE p1.name = 'sort_area_size'
			AND p2.name = 'hash_area_size';
			
		- Par�metros de configura��o da PGA:
			alter system set pga_aggregate_target = 400M;
				
				Valor padr�o: 10MB ou 20% do tamanho do SGA, o que for maior
			
			alter system set pga_aggregate_limit = 2G;
			
				Valor padr�o: Se MEMORY_TARGET estiver definido, PGA_AGGREGATE_LIMIT o padr�o ser� o valor MEMORY_MAX_TARGET.
				Se MEMORY_TARGET n�o for definido, o PGA_AGGREGATE_LIMIT padr�o ser� 200% de PGA_AGGREGATE_TARGET.
				Se MEMORY_TARGET n�o for definido e PGA_AGGREGATE_TARGET for explicitamente definido como 0, o valor de PGA_AGGREGATE_LIMIT ser� definido como 90% do tamanho da mem�ria f�sica menos o tamanho total do SGA.
				Em todos os casos, o padr�o PGA_AGGREGATE_LIMIT � pelo menos 2GB e pelo menos 3MB x o par�metro PROCESSES (e pelo menos 5MB x o par�metro PROCESSES para uma inst�ncia do Oracle RAC).
				Obs: Surgiu na vers�o 12c
				
				
--> Quando Otimizar a PGA? 

	- Sinais de que o PGA precisa ser otimizado: Se voc� perceber que h� muitas leituras de disco ou que as consultas est�o mais lentas do que o esperado, pode ser um sinal de que a PGA precisa de mais mem�ria.
	- Dicas de Otimiza��o: Al�m de ajustar o parametro PGA_AGGREGATE_TARGET, voc� tamb�m pode revisar as consultas mais pesadas, otimizando joins e evitando opera��es que sobrecarregam o uso da PGA.


--> Dica

	- Ferramenta para monitorar a PGA  
		Enterprise Manager Cloud Control
		Enterprise Manager Express
		oratop