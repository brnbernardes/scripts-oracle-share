-- Versions / Features
 SELECT * FROM V$VERSION;   
 SELECT * FROM V$OPTION ORDER BY 2,1;
 SELECT name, version, detected_usages, description FROM DBA_FEATURE_USAGE_STATISTICS ORDER BY 3 DESC, 1;
 SELECT comp_id,comp_name, version, status, modified, schema, procedure FROM dba_registry  ORDER BY 1;


--FEATURE USAGE
column name  format a60
column detected_usages format 999999999999
select u1.name,
       u1.detected_usages,
       u1.currently_used,
       u1.version
from   dba_feature_usage_statistics u1
where  u1.version = (select max(u2.version)
                     from   dba_feature_usage_statistics u2
                     where  u2.name = u1.name)
and    u1.detected_usages > 0
and    u1.dbid = (select dbid from v$database)
and    u1.upper(name) LIKE '%TUNING%'
order by name;

--SCHEMAS ORACLE:
 SELECT DISTINCT owner
  FROM dba_segments
 WHERE owner IN
       (SELECT username
          FROM dba_users
         WHERE default_tablespace IN ('SYSTEM', 'SYSAUX'));
