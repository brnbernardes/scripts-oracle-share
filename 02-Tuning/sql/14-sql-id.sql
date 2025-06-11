SQL> set feedback only sql_id
SQL> SELECT * FROM SCOTT.EMP;
14 rows selected.

SQL_ID: 4ay6mhcbhvbf2

-----------------------------------------------------------------------------------------------------------------------

SQL> set feedback on
SQL> select dbms_sql_translator.sql_id('SELECT * FROM SCOTT.EMP')
  2  from   dual;

DBMS_SQL_TRANSLATOR.SQL_ID('SELECT*FROMSCOTT.EMP')
----------------------------------------------------
4ay6mhcbhvbf2

1 row selected.