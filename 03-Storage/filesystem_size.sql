
SELECT trunc(SYSDATE) date_time,
       (SELECT host_name FROM v$instance) "HOST_NAME",
       (SELECT round(SUM(bytes) / 1024 / 1024, 2) AS database_used_size
          FROM dba_segments) "DATABASE_USED_SIZE_MB",
       (SELECT round(SUM(bytes) / 1024 / 1024, 2) AS database_free_size
          FROM dba_free_space) "DATABASE_FREE_SIZE_MB",
       (SELECT round(SUM(bytes) / 1024 / 1024, 2) FROM dba_data_files) "DATAFILE_SIZES_MB",
       (SELECT round(SUM(bytes) / 1024 / 1024, 2) AS total_size
          FROM dba_temp_files) "TEMPFILES_SIZE_MB",
       (SELECT round(SUM(block_size * file_size_blks) / 1024 / 1024, 2) AS total_size
          FROM v$controlfile) "CONTROLFILES_SIZE_MB",
       (SELECT round(SUM(bytes / 1024 / 1024), 2) AS total_size
          FROM v$log l, v$logfile f
         WHERE l.group# = f.group#) "LOGFILES_SIZE_MB",
       (SELECT nvl(round(SUM(bytes / 1024 / 1024), 2), 0) AS total_size
          FROM v$standby_log l, v$logfile f
         WHERE l.group# = f.group#) "STANDBY_LOG_SIZE_MB",
       (SELECT SUM(total_size) "FILE_SYSTEM_SIZE_DISK"
          FROM (SELECT round(SUM(bytes) / 1024 / 1024, 2) AS total_size
                  FROM dba_data_files
                UNION ALL
                SELECT round(SUM(bytes) / 1024 / 1024, 2) AS total_size
                  FROM dba_temp_files
                UNION ALL
                SELECT round(SUM(block_size * file_size_blks) / 1024 / 1024, 2) AS total_size
                  FROM v$controlfile
                UNION ALL
                SELECT round(SUM(bytes / 1024 / 1024), 2) AS total_size
                  FROM v$log l, v$logfile f
                 WHERE l.group# = f.group#
                UNION ALL
                SELECT nvl(round(SUM(bytes / 1024 / 1024), 2), 0) AS total_size
                  FROM v$standby_log l, v$logfile f
                 WHERE l.group# = f.group#)) "FILE_SYSTEM_SIZE_DISK_MB",
       (SELECT log_mode FROM v$database) "LOG_MODE",
       (SELECT flashback_on FROM v$database) "FLASHBACK_ON",
       (SELECT COUNT(*) restore_point FROM v$restore_point) "RESTORE_POINT",
       (SELECT status FROM v$block_change_tracking) "BLOCK_CHANGE_TRACKING_STATUS",
       (SELECT nvl(filename, 'NONE') FROM v$block_change_tracking) "BLOCK_CHANGE_TRACKING_FILE"
  FROM dual;