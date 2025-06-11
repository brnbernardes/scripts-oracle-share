
/*
du -shc ./* 2>/dev/null | sort -h
find . -mtime +10

*/

SELECT * FROM dba_data_files WHERE FILE_NAME like '%arquivamento01.dbf%';

SELECT FILE_NAME, round(BYTES/1024/1024/1024, 2) gbytes FROM DBA_DATA_FILES WHERE TABLESPACE_NAME = 'ARQUIVAMENTO';

SELECT * FROM DBA_DATA_FILES WHERE TABLESPACE_NAME = 'ARQUIVAMENTO';

ALTER TABLESPACE ARQUIVAMENTO OFFLINE NORMAL;

! cp /ora/app/oracle/oradata/tjal/arquivamento01.dbf /ora2/oracle/oradata/tjal/arquivamento01.dbf

ALTER TABLESPACE ARQUIVAMENTO RENAME DATAFILE '/ora/app/oracle/oradata/tjal/arquivamento01.dbf' TO '/ora2/oracle/oradata/tjal/arquivamento01.dbf';

ALTER TABLESPACE ARQUIVAMENTO ONLINE;

! rm -f /ora/app/oracle/oradata/tjal/arquivamento01.dbf
