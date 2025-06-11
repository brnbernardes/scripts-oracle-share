----------------------------------------
prompt TOP_SES_IO.SQL - TOP SESSIONS IO
----------------------------------------
prompt Oracle background process will not be shown.

set lines 2000
set pages 100
set echo off
Set serveroutput on size 1000000
alter session set nls_date_format='dd-mon-yy hh24:mi:ss';

COLUMN sid               FORMAT 99999              
COLUMN serial_id         FORMAT 999999           
COLUMN status    	 FORMAT a9               
COLUMN oracle_username   FORMAT a12              
COLUMN os_username       FORMAT a9               
COLUMN spid            	 FORMAT a6          
COLUMN program   	 FORMAT a18              
COLUMN machine   	 FORMAT a14               
COLUMN logical_io        FORMAT 999,999,999,999  HEADING 'Logical I/O(Total)'
COLUMN physical_reads    FORMAT 999,999,999,999  HEADING 'Physical Reads(Total)'
COLUMN physical_writes   FORMAT 999,999,999,999  HEADING 'Physical Writes(Total)'

COLUMN inst		FORMAT 99
prompt Activity parameter: A = Actives ,  I = Inactives , No answer = both
DEFINE activity 	= &activity || '' 

SELECT * 
 from (	SELECT	   /*+ rule */
		   lpad(s.username,12)  		oracle_username,
		   s.inst_id				inst,
		   s.sid                		sid,
		   lpad(p.spid,5)       		spid,
		   lpad(s.status,9)     		status,
		   lpad(s.osuser,9)     		os_username,
		   substr(s.program,1,10) 		program,
		   lpad(s.machine,14)     		machine,
		   sstat1.value + sstat2.value         	logical_io,
		   sstat3.value         		physical_reads,
		   sstat4.value         		physical_writes
	FROM 	gv$process  p,
	   	gv$session  s,
	   	gv$sesstat  sstat1,
	   	gv$sesstat  sstat2,
	   	gv$sesstat  sstat3,
	   	gv$sesstat  sstat4,
	   	gv$statname statname1,
	   	gv$statname statname2,
	   	gv$statname statname3,
	   	gv$statname statname4
	WHERE p.addr (+)            = s.paddr
	  AND p.inst_id (+)	  = s.inst_id
	  AND s.sid                 = sstat1.sid
	  AND s.inst_id             = sstat1.inst_id
	  AND s.sid                 = sstat2.sid
	  AND s.inst_id             = sstat2.inst_id
	  AND s.sid                 = sstat3.sid
	  AND s.inst_id             = sstat3.inst_id
	  AND s.sid                 = sstat4.sid
	  AND s.inst_id             = sstat4.inst_id
	  AND statname1.statistic#  = sstat1.statistic#
	  AND statname1.inst_id	    = sstat1.inst_id
	  AND statname2.statistic#  = sstat2.statistic#
	  AND statname2.inst_id	    = sstat2.inst_id
	  AND statname3.statistic#  = sstat3.statistic#
	  AND statname3.inst_id	    = sstat3.inst_id
	  AND statname4.statistic#  = sstat4.statistic#
	  AND statname4.inst_id	    = sstat4.inst_id
	  AND statname1.name        = 'db block gets'
	  AND statname2.name        = 'consistent gets'
	  AND statname3.name        = 'physical reads'
	  AND statname4.name        = 'physical writes'
	  --AND s.inst_id		  = nvl('&inst_id',s.inst_id)
   	  --AND s.status		  = decode(upper('&activity'),'A','ACTIVE','I','INACTIVE',s.status)
	  AND s.username	  is not null
	ORDER BY logical_io DESC
	) X
 WHERE ROWNUM <= 15;

UNDEFINE activity
clear columns