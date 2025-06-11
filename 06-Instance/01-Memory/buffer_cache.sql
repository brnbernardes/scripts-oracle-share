--> O que é o "Database Buffer Cache" e como ele impacta a performance?

--> Ambiente

	Oracle Linux 8
	SGBD Oracle 19c
	Enterprise Edition (Valido para qualquer edition)
	Single Instance (Valido para RAC)
	NonCDB (Valido para CDB)
	
	
--> Objetivo do video
	
	- Entender o que é o Database Buffer Cache, entender seu impacto na performance e como monitorar e possivelmente aplicar melhorias.
	
	
--> O Que é o Database Buffer Cache? 

	- O Database Buffer Cache é uma área da SGA onde o Oracle armazena os blocos de dados que foram lidos recentemente do disco.
	- Analogia: "Pense nele como a memória RAM do seu computador. Se o dado já estiver lá, o Oracle não precisa buscar no disco, o que deixa tudo muito mais rápido!"
	
	
--> Como o Database Buffer Cache impacta a performance? 

	- Quando uma consulta é executada, o Oracle primeiro verifica se os dados já estão no Database Buffer Cache. Se sim, ele lê diretamente da memória (muito rápido!). Se não, ele precisa buscar no disco (muito mais lento!)."
	
	
--> Demonstração prática 

	- Simular varias conexões
	
	- Como monitorar o uso do Database Buffer Cache
	
		- Ver total 
		
			SET pagesize 400;
			SET linesize 400;
			SELECT component,
			current_size/1024/1024 "Tamanho Atual",
			min_size    /1024/1024 "Tamanho Minimo",
			max_size    /1024/1024 "Tamanho Maximo"
			FROM v$memory_dynamic_components;
			
	
		- Ver a quantidade de leituras
	
			SELECT name, value 
			FROM v$sysstat 
			WHERE name IN ('db block gets', 'consistent gets', 'physical reads');

				db block gets ? Blocos lidos diretamente do Database Buffer Cache.
				consistent gets ? Blocos lidos de forma consistente.
				physical reads ? Blocos lidos do disco (quanto menor, melhor).
	
				
--> Como melhorar a eficiência do Database Buffer Cache?

	- Avaliar taxa de acerto 
	
		SELECT inst_id, 'DICTIONARY_CACHE' ,100 - round((sum(getmisses)/sum(gets))*100,2) as "DICTIONARY_CACHE" 
		FROM gv$rowcache
		GROUP BY inst_id;
		
	- Dicas práticas para otimizar o uso da memória.
	
		- Ajuste do tamanho do Database Buffer Cache:
			show parameters db_cache_size;
			alter system set db_cache_size = 200M;
		- Índices bem planejados ? Reduzem a necessidade de leituras no disco.
		- Uso de tabelas corretamente particionadas ? Melhora a eficiência da leitura.
		- Evitar FULL TABLE SCAN desnecessários ? Consultas mal escritas podem prejudicar o uso do cache.
		- Aumentar a memoria do banco de dados 
			https://youtu.be/_IolkkTWnWA?si=Xu643drZOwupKodd
			

--> Dica

	- Ferramentas para monitorar a memoria   
		Enterprise Manager Cloud Control
		Enterprise Manager Express
		oratop