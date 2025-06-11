set lines 200 pages 999
break on version skip 1
SELECT version,
       NAME,
       detected_usages,
       currently_used,
       first_usage_date,
       last_usage_date
  FROM dba_feature_usage_statistics
 WHERE detected_usages > 0
 ORDER BY 1, 2;