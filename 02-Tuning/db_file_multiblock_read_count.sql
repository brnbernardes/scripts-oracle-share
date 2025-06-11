-- db_file_multiblock_read_count

show parameters db_file_multiblock_read_count

-- 1) 
alter system flush buffer_cache;
set timing on
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;

--2)
alter session set db_file_multiblock_read_count = 0;
alter system flush buffer_cache;
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;

--3)
alter session set db_file_multiblock_read_count = 128;
alter system flush buffer_cache;
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;

--4)
alter session set db_file_multiblock_read_count = 512;
alter system flush buffer_cache;
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;

--5)
alter session set db_file_multiblock_read_count = 124;
alter system flush buffer_cache;
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;

alter session set db_file_multiblock_read_count = 32768;
alter system flush buffer_cache;
SELECT /*+ FULL(t) */ COUNT(1) FROM erp.tri$_histcalcimp_e t;