--0) SGA size
SELECT NAME, round(value/1024/1024) mbytes FROM v$sga;

--1) Consulte as estatísticas relacionadas ao Buffer Cache
SELECT NAME, VALUE FROM v$sysstat WHERE NAME LIKE '%buffer%';

--2) Estime o desempenho com vários tamanhos para o Buffer Cache e diferentes tamanhos de bloco de banco de dados
--   Avaliar Buffer Cache através de advisor, o parâmetro db_cache_advice deve estar ON
--COLUMN size_for_estimate FORMAT 999,999,999,999 heading 'Cache Size (MB)'
--COLUMN buffers_for_estimate FORMAT 999,999,999 heading 'Buffers'
--COLUMN estd_physical_read_factor FORMAT 999.90 heading 'Estd PhysRead Factor'
--COLUMN estd_physical_reads FORMAT 999,999,999,999 heading 'Estd Phys Reads'
SELECT size_for_estimate,
       buffers_for_estimate,
       estd_physical_read_factor,
       estd_physical_reads
  FROM v$db_cache_advice
 WHERE NAME = 'DEFAULT'
   AND block_size = (SELECT VALUE FROM v$parameter WHERE NAME = 'db_block_size')
   AND advice_status = 'ON';

--3) Avalie a taxa de acertos do Buffer Cache a partir das estatísticas
SELECT pr.value AS "phy. reads",
       prd.value AS "phy. reads direct",
       prdl.value AS "phy. reads direct (lob)",
       slr.value AS "session logical reads",
       1 - (pr.value - prd.value - prdl.value) / slr.value AS "hit ratio"
  FROM v$sysstat pr, v$sysstat prd, v$sysstat prdl, v$sysstat slr
 WHERE pr.name = 'physical reads'
   AND prd.name = 'physical reads direct'
   AND prdl.name = 'physical reads direct (lob)'
   AND slr.name = 'session logical reads';
   
--4) Avalie as estatísticas e a taxa de acertos para vários Buffer Pools:
SELECT NAME,
       physical_reads AS "physical reads",
       db_block_gets AS "DB block gets",
       consistent_gets AS "consistent gets",
       1 - (physical_reads / (db_block_gets + consistent_gets)) AS "hit ratio"
  FROM v$buffer_pool_statistics
 WHERE db_block_gets + consistent_gets > 0;


