variable blksize number;
begin
  select value into :blksize from v$parameter where name = 'db_block_size';
end;
/

-----------
-- Resize
WITH dba_resize AS
 (SELECT a.file_id,
         a.file_name,
         a.tablespace_name,
         ceil((nvl(hwm, 1) * &blksize) / 1024) +100 smallest_kb,  --> +100 para sobra no calculo
         ceil(blocks * &blksize / 1024/1024) currsize_mb,
         ceil(blocks * &blksize / 1024 / 1024) - ceil((nvl(hwm, 1) * &blksize) / 1024 / 1024) savings_mb
    FROM dba_data_files a,
         (SELECT file_id, MAX(block_id + blocks - 1) hwm
            FROM dba_extents
           GROUP BY file_id) b
   WHERE a.file_id = b.file_id)
SELECT r.file_id, r.tablespace_name, currsize_mb, savings_mb, 'ALTER DATABASE DATAFILE ''' || r.file_name || ''' RESIZE ' || smallest_kb || 'K;' cmd
  FROM dba_resize r
WHERE savings_mb > 0
ORDER BY savings_mb DESC;