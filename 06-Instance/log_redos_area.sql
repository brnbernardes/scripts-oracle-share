SQL> show parameters db_create_file_dest
SQL> show parameters db_recovery

----------------------------------------------------------------------------------------------------------------

SET lines 200 pages 999
COL directory for a40
SELECT name "directory",
       (space_limit / 1024 / 1024) "space_limit(mb)",
       (space_used / 1024 / 1024) "space_used(mb)",
       (space_reclaimable / 1024 / 1024) "space_reclaimable(mb)",
       NUMBER_OF_FILES "number_of_files"
 FROM V$RECOVERY_FILE_DEST;

----------------------------------------------------------------------------------------------------------------

SELECT name "directory",
       round((space_limit / 1024 / 1024 / 1024),2) "space_limit(gb)",
       round((space_used / 1024 / 1024 / 1024),2) "space_used(gb)",
       round((space_reclaimable / 1024 / 1024 / 1024),2) "space_reclaimable(gb)", --recuperável
       NUMBER_OF_FILES "number_of_files"
  FROM V$RECOVERY_FILE_DEST;


----------------------------------------------------------------------------------------------------------------

SELECT * FROM V$RECOVERY_AREA_USAGE;

