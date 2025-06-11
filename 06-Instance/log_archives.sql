SELECT to_char(completion_time, 'DD/MM/YYYY') DAY,
       SUM(decode(to_char(completion_time, 'HH24'), '00', 1, NULL)) "00",
       SUM(decode(to_char(completion_time, 'HH24'), '01', 1, NULL)) "01",
       SUM(decode(to_char(completion_time, 'HH24'), '02', 1, NULL)) "02",
       SUM(decode(to_char(completion_time, 'HH24'), '03', 1, NULL)) "03",
       SUM(decode(to_char(completion_time, 'HH24'), '04', 1, NULL)) "04",
       SUM(decode(to_char(completion_time, 'HH24'), '05', 1, NULL)) "05",
       SUM(decode(to_char(completion_time, 'HH24'), '06', 1, NULL)) "06",
       SUM(decode(to_char(completion_time, 'HH24'), '07', 1, NULL)) "07",
       SUM(decode(to_char(completion_time, 'HH24'), '08', 1, NULL)) "08",
       SUM(decode(to_char(completion_time, 'HH24'), '09', 1, NULL)) "09",
       SUM(decode(to_char(completion_time, 'HH24'), '10', 1, NULL)) "10",
       SUM(decode(to_char(completion_time, 'HH24'), '11', 1, NULL)) "11",
       SUM(decode(to_char(completion_time, 'HH24'), '12', 1, NULL)) "12",
       SUM(decode(to_char(completion_time, 'HH24'), '13', 1, NULL)) "13",
       SUM(decode(to_char(completion_time, 'HH24'), '14', 1, NULL)) "14",
       SUM(decode(to_char(completion_time, 'HH24'), '15', 1, NULL)) "15",
       SUM(decode(to_char(completion_time, 'HH24'), '16', 1, NULL)) "16",
       SUM(decode(to_char(completion_time, 'HH24'), '17', 1, NULL)) "17",
       SUM(decode(to_char(completion_time, 'HH24'), '18', 1, NULL)) "18",
       SUM(decode(to_char(completion_time, 'HH24'), '19', 1, NULL)) "19",
       SUM(decode(to_char(completion_time, 'HH24'), '20', 1, NULL)) "20",
       SUM(decode(to_char(completion_time, 'HH24'), '21', 1, NULL)) "21",
       SUM(decode(to_char(completion_time, 'HH24'), '22', 1, NULL)) "22",
       SUM(decode(to_char(completion_time, 'HH24'), '23', 1, NULL)) "23",
       COUNT(*) total
  FROM v$archived_log
 WHERE archived = 'YES'
   AND trunc(completion_time) >= trunc(SYSDATE - 7)
 GROUP BY to_char(completion_time, 'DD/MM/YYYY')
 ORDER BY to_date(DAY, 'DD/MM/YYYY');