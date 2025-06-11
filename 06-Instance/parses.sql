-- Verificar % de hard parses: hard*100/total
SELECT NAME,
       VALUE
  FROM v$sysstat
 WHERE NAME IN ('parse count (total)', 'parse count (hard)');