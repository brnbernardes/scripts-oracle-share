--PGA Target: Advice
SELECT round(pga_target_for_estimate / 1024 / 1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
  FROM v$pga_target_advice;



--> Entendendo o papel da PGA nas sessões no banco de dados Oracle

--> Ambiente

	Oracle Linux 8
	SGBD Oracle 19c
	Enterprise Edition (Valido para qualquer edition)
	Single Instance (Valido para RAC)
	NonCDB (Valido para CDB)
	
	
--> Objetivo do video
	
	- Você vai entender o que é a PGA, como ele afeta o desempenho das sessões e por que é tão importante para a administração do banco de dados Oracle.
	
	
--> O que é a PGA?  

	- Definição: A PGA é uma área de memória dedicada a cada sessão no Oracle. Ela é usada para armazenar informações específicas da sessão, como variáveis de bind, informações de cursores e o espaço de memória para operações de sorting e joins.
	- Componentes Importantes da PGA: Dentro da PGA, temos componentes como o Private SQL Area e o Sort Area, que são essenciais para a execução de consultas e manipulação de dados.
	- Relação com a SGA: É importante saber que a PGA é diferente da SGA (System Global Area), que é compartilhado entre todas as sessões. A PGA, por sua vez, é dedicado exclusivamente a cada sessão.
	
	
--> Como a PGA Afeta o Desempenho das Sessões? 

	- Uso da PGA nas Sessões: Cada vez que uma sessão é iniciada, o Oracle aloca uma área da PGA para ela e libera quando a sessão desconecta. A quantidade de memória disponível na PGA pode influenciar diretamente o desempenho dessa sessão.
	- Exemplo Prático: Se uma sessão consome muita PGA, por exemplo, ao realizar um join complexo ou uma ordenação de dados muito grande, isso pode impactar o desempenho, fazendo com que o Oracle precise recorrer à troca de memória com o disco usando a tablespace temporaria, o que é muito mais lento.
	- Quando a PGA é um Problema: Se a PGA estiver configurado com um valor muito baixo, você pode ver muitas operações de disco, o que vai gerar um impacto negativo no desempenho.


--> Demonstração prática 

	-- Simular varias conexões

	-- Como monitorar o uso da PGA
	
		- Visualizar uso atual por sessão 
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
			
			--> PGA_USED_MEM: Memória PGA atualmente usada pelo processo (em bytes)
			--> PGA_ALLOC_MEM: Memória PGA atualmente alocada pelo processo (incluindo memória PGA livre ainda não liberada para o sistema operacional pelo processo do servidor (em bytes)
			--> PGA_FREEABLE_MEM: Memória PGA alocada que pode ser liberada (em bytes)
			--> PGA_MAX_MEM: Memória PGA máxima já alocada pelo processo (em bytes)
		
		- Total de PGA usada no momento
		
			SELECT name.name,sum(stat.value)/1024/1024 PGA_MB
			FROM v$statname name, v$sesstat stat
			WHERE name.statistic#=stat.statistic#
			AND name.name LIKE '%pga%'
			GROUP BY name.name;
			
		- Eliminando sessão que esta consumindo muita PGA 
		
			set linesize 200;
			set pagesize 10000;
			SELECT 'alter system disconnect session ''' || sid|| ',' ||serial# || ',@'||inst_id||''' immediate;'
			FROM gv$session 
			WHERE type != 'BACKGROUND';
		
		
	- Ajustando o Tamanho do PGA
	
		- Visualizar configuração atual 
		
			show parameters pga_aggregate_target;
			show parameters pga_aggregate_limit;
			
		- Dica para configuração do tamanho da PGA 
		
			SELECT &max_connected_sessions*(2048576+p1.value+p2.value)/(1024*1024) as you_need_pga_mb 
			FROM v$parameter p1, v$parameter p2
			WHERE p1.name = 'sort_area_size'
			AND p2.name = 'hash_area_size';
			
		- Parâmetros de configuração da PGA:
			alter system set pga_aggregate_target = 400M;
				
				Valor padrão: 10MB ou 20% do tamanho do SGA, o que for maior
			
			alter system set pga_aggregate_limit = 2G;
			
				Valor padrão: Se MEMORY_TARGET estiver definido, PGA_AGGREGATE_LIMIT o padrão será o valor MEMORY_MAX_TARGET.
				Se MEMORY_TARGET não for definido, o PGA_AGGREGATE_LIMIT padrão será 200% de PGA_AGGREGATE_TARGET.
				Se MEMORY_TARGET não for definido e PGA_AGGREGATE_TARGET for explicitamente definido como 0, o valor de PGA_AGGREGATE_LIMIT será definido como 90% do tamanho da memória física menos o tamanho total do SGA.
				Em todos os casos, o padrão PGA_AGGREGATE_LIMIT é pelo menos 2GB e pelo menos 3MB x o parâmetro PROCESSES (e pelo menos 5MB x o parâmetro PROCESSES para uma instância do Oracle RAC).
				Obs: Surgiu na versão 12c
				
				
--> Quando Otimizar a PGA? 

	- Sinais de que o PGA precisa ser otimizado: Se você perceber que há muitas leituras de disco ou que as consultas estão mais lentas do que o esperado, pode ser um sinal de que a PGA precisa de mais memória.
	- Dicas de Otimização: Além de ajustar o parametro PGA_AGGREGATE_TARGET, você também pode revisar as consultas mais pesadas, otimizando joins e evitando operações que sobrecarregam o uso da PGA.


--> Dica

	- Ferramenta para monitorar a PGA  
		Enterprise Manager Cloud Control
		Enterprise Manager Express
		oratop