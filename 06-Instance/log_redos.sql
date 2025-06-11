-- adicionar grupo de redologs
ALTER DATABASE ADD LOGFILE GROUP <grupo_número> ('<caminho_do_logfile>') SIZE <tamanho> [REUSE];

ALTER DATABASE ADD LOGFILE GROUP 5 (
  '/u01/app/oracle/oradata/ORCL/redo05a.log',
  '/u02/app/oracle/oradata/ORCL/redo05b.log'
) SIZE 200M;


set lines 200
set pages 2000
col GROUP_MEMBER for a90
SELECT l.group# group_number,
       l.thread#,
       l.sequence#,
       l.bytes / 1024 / 1024 AS size_mb,
       l.status group_status,
       f.member group_member,
       l.archived
  FROM v$log     l,
       v$logfile f
 WHERE l.group# = f.group#
 ORDER BY  l.thread#, l.sequence#;



SELECT to_date(to_char(first_time, 'DD/MM/YYYY'), 'DD/MM/YYYY') data,
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '00', 1,0)), '999') "00",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '01', 1,0)), '999') "01",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '02', 1,0)), '999') "02",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '03', 1,0)), '999') "03",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '04', 1,0)), '999') "04",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '05', 1,0)), '999') "05",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '06', 1,0)), '999') "06",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '07', 1,0)), '999') "07",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '08', 1,0)), '999') "08",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '09', 1,0)), '999') "09",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '10', 1,0)), '999') "10",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '11', 1,0)), '999') "11",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '12', 1,0)), '999') "12",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '13', 1,0)), '999') "13",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '14', 1,0)), '999') "14",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '15', 1,0)), '999') "15",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '16', 1,0)), '999') "16",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '17', 1,0)), '999') "17",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '18', 1,0)), '999') "18",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '19', 1,0)), '999') "19",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '20', 1,0)), '999') "20",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '21', 1,0)), '999') "21",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '22', 1,0)), '999') "22",
       to_char(SUM(decode(substr(to_char(first_time, 'HH24'), 1, 2), '23', 1,0)), '999') "23",
       SUM(1) "TOTAL_IN_DAY"
  FROM v$log_history
WHERE first_time >= trunc(sysdate)
 GROUP BY to_char(first_time, 'DD/MM/YYYY')
 ORDER BY data;
