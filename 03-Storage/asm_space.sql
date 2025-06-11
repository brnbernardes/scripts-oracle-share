----------------------------------------
-- asm_space.sql - ASM SPACE
-- Define diskgroups, space consumed and available.
----------------------------------------
set lines 300
set pages 999
col NAME for a30
col allocation_unit_size for 9999999999
col compatibility for a15
col name for a10
col database_compatibility for a22
SELECT group_number,
       NAME,
       total_mb / 1024 total_gb,
       free_mb / 1024 total_free_gb,
       round(((free_mb / total_mb) * 100), 2) perct_free,
       compatibility,
       database_compatibility,
       allocation_unit_size
  FROM v$asm_diskgroup
 ORDER BY 1;


SELECT 
  nvl(status, 0) status, 
  resultado 
FROM 
  (
    SELECT 
      MAX(
        CASE WHEN free_mb <= 30720 AND perc_free < 15 AND perc_free > 5 THEN '1' 
             WHEN free_mb <= 30720 AND perc_free < 5 THEN '2' 
             ELSE '0' 
             END) status, 
      LISTAGG('O diskgroup +' || NAME || ' possui ' || perc_free || '% livre (' || to_char(round(free_mb/1024,2),'FM999G999G990D00') ||'GB)', ', ') WITHIN GROUP(ORDER BY NAME) AS resultado 
    FROM 
      (
        select name, total_mb, free_mb, round(((free_mb * 100)/ total_mb), 2) perc_free from v$asm_diskgroup
      )
  );


SELECT 
  nvl(status, 0) status, 
  resultado 
FROM 
  (
    SELECT 
      MAX(CASE WHEN perc_free < 15 AND perc_free > 5 THEN '1' WHEN perc_free < 5 THEN '2' ELSE '0' END) status, 
      LISTAGG('O diskgroup +' || NAME || ' possui ' || perc_free || '% livre', ', ') WITHIN GROUP(ORDER BY NAME) AS resultado 
    FROM 
      (
        select 
          name, 
          total_mb, 
          free_mb, 
          round(
            (
              (free_mb * 100)/ total_mb
            ), 
            2
          ) perc_free 
        from 
          v$asm_diskgroup
      )
  );