-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/script_creation/logon_as_user_orig.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific user.
--                Better approaches included here.
--                https://oracle-base.com/articles/misc/proxy-users-and-connect-through
-- Call Syntax  : @logon_as_user_orig (username)
-- Last Modified: 06/06/2019 - Added link to article.
-- -----------------------------------------------------------------------------------

set serveroutput on verify off
declare
  l_username VARCHAR2(30) :=  upper('&1');
  l_orig_pwd VARCHAR2(32767);
begin 
  select password
  into   l_orig_pwd
  from   dba_users
  where  username = l_username;

  dbms_output.put_line('--');
  dbms_output.put_line('alter user ' || l_username || ' identified by DummyPassword1;');
  dbms_output.put_line('conn ' || l_username || '/DummyPassword1');

  dbms_output.put_line('--');
  dbms_output.put_line('-- Do something here.');
  dbms_output.put_line('--');

  dbms_output.put_line('conn / as sysdba');
  dbms_output.put_line('alter user ' || l_username || ' identified by values '''||l_orig_pwd||''';');
end;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Proxy manual
SET LONG 10000
SET PAGESIZE 1000
COL alter_user_sql FOR a200
SELECT 'ALTER USER ' || name || ' IDENTIFIED BY VALUES ''' || REPLACE(spare4, CHR(10), '') || ''';' AS alter_user_sql FROM sys.user$ WHERE NAME = 'PMCS';


ALTER USER PMCS IDENTIFIED BY VALUES 'S:E79BAD337BE1336EEE4D1A4769B464E69BC55E2CF80B101B1DDABC71A121;T:D545320E8E77AB9B626B48E5256D436940E0A261599A4858D1F04DEB5A1F5010EF867C91C4E014A679DA15ABA301E694C3A933374A574DAEE40FEEA4423FA9581515A4F1749258E0232CCD2E3A503477';