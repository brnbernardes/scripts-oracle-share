-- Listar datafiles e utilização 
SET PAGESIZE 1000 
SET LINESIZE 150
SET TIMING ON
COL name FORMAT A20 HEAD "TABLESPACE" 
COL file_name FORMAT A60 HEAD "DATA_FILE" 
COL a FORMAT 999999999999 HEAD "TAMANHO(MB)" 
COL b FORMAT 999999999999 HEAD "USADO(MB)" 
COL c FORMAT 999999999999 HEAD "LIVRE(MB)" 
COL d FORMAT A11 HEAD "%_USADO" 
COL e FORMAT A3 HEAD "AUTO_EXTENSIVO" 
COL f FORMAT 999999999999 HEAD "MAXIMO(MB)" 
BREAK ON REPORT 
COMPUTE SUM OF KBYTES ON REPORT 
COMPUTE SUM OF FREE ON REPORT 
COMPUTE SUM OF USED ON REPORT 
SELECT df.file_id,
       substr(df.tablespace_name, 1, 20) NAME,
       df.file_name,
       round(df.bytes / 1024 / 1024, 2) a,
       round(e.used_bytes / 1024 / 1024, 2) b,
       round(f.free_bytes / 1024 / 1024, 2) c,
       rpad(' ' || rpad('X', round(e.used_bytes * 10 / df.bytes, 0), 'X'),11, '-') d,
       df.autoextensible e,
       round(maxbytes / 1024 / 1024, 2) f
  FROM dba_data_files df,
       (SELECT file_id, SUM(decode(bytes, NULL, 0, bytes)) used_bytes
          FROM dba_extents
         GROUP BY file_id) e,
       (SELECT MAX(bytes) free_bytes, file_id
          FROM dba_free_space
         GROUP BY file_id) f
 WHERE e.file_id(+) = df.file_id
   AND df.file_id = f.file_id(+)
   --AND df.tablespace_name IN ('DATA')
 ORDER BY df.tablespace_name, df.file_name;
