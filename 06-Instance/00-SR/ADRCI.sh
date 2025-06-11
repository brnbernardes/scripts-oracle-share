SQL> 
col name for a30
col value for a100
SELECT name, value FROM v$diag_info;

NAME                           | VALUE
------------------------------ | ------------------------------------------------------------------------------------
Diag Enabled                   | TRUE
ADR Base                       | /u01/app/oracle
ADR Home                       | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT
Diag Trace                     | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/trace
Diag Alert                     | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/alert
Diag Incident                  | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/incident
Diag Cdump                     | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/cdump
Health Monitor                 | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/hm
Default Trace File             | /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/trace/THEMALT_ora_742.trc
Active Problem Count           | 24
Active Incident Count          | 268
ORACLE_HOME                    | /u01/app/oracle/product/19.0.0.0/dbhome_1

-----------------------------------------------------------------------------------------------------------------------

$ adrci
adrci> show home
ADR Homes:
diag/kfod/srv-oracle-themacdblite/kfod
diag/diagtool/user_oracle/adrci_3570951873_110
diag/rdbms/unknown/THEMALT
diag/rdbms/themalt_gru19s/THEMALT
diag/rdbms/dddd_pitr_pmtoquep_themalt/dddD
diag/asmcmd/user_grid/srv-oracle-themacdblite
diag/asmcmd/user_oracle/srv-oracle-themacdblite
diag/asmtool/user_oracle/host_3570951873_110

adrci> set home diag/rdbms/themalt_gru19s/THEMALT

adrci> show problem
ADR Home = /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT:
*************************************************************************
PROBLEM_ID           PROBLEM_KEY                                                 LAST_INCIDENT        LASTINC_TIME
-------------------- ----------------------------------------------------------- -------------------- ----------------------------------------
23                   ORA 7445 [__intel_avx_rep_memcpy]                           425552               2023-02-16 17:39:35.541000 -03:00
11                   ORA 7445 [kgiSwitchHandle]                                  424840               2023-03-01 13:22:12.282000 -03:00
12                   ORA 600 [kglUnLock-bad-lock]                                425656               2023-03-31 09:57:03.349000 -03:00
25                   ORA 7445 [_intel_fast_memcmp]                               428848               2023-04-10 10:26:32.284000 -03:00
24                   ORA 7445 [kgghash]                                          436392               2023-04-10 13:21:15.484000 -03:00
17                   ORA 6544 [pevm_peruws_callback-1]                           1068239              2023-08-01 14:06:02.899000 -03:00
30                   ORA 600 [729]                                               1069826              2023-09-02 18:46:33.265000 -03:00
22                   ORA 600 [20084]                                             1070703              2023-10-24 10:16:41.903000 -03:00
9                    ORA 3137 [3146]                                             1085104              2023-10-24 14:12:34.396000 -03:00
16                   ORA 600 [16632]                                             1068687              2023-11-01 23:59:40.358000 -03:00
28                   ORA 445                                                     1063401              2023-11-08 08:55:32.169000 -03:00
34                   ORA 600 [pfrsfm: Stack disordered]                          1146254              2023-11-23 09:35:26.311000 -03:00
35                   ORA 6544                                                    1391573              2023-12-29 18:38:54.364000 -03:00
33                   ORA 7445 [kkqojeanl]                                        1394802              2024-01-04 09:36:35.437000 -03:00
29                   ORA 600 [HO define: Long fetch]                             1390435              2024-01-10 15:39:46.933000 -03:00
31                   ORA 600 [OCIKNSECA-2]                                       1394146              2024-01-10 16:06:58.034000 -03:00
32                   ORA 600 [kxsclsr-1]                                         1394148              2024-01-10 16:07:09.286000 -03:00
26                   ORA 800                                                     1408982              2024-01-22 22:38:51.873000 -03:00
36                   ORA 7445 [qcsAnalyzeExpr_ProcessKids]                       1427014              2024-02-05 09:40:26.485000 -03:00
3                    ORA 7445 [kggmd5Process]                                    1426054              2024-02-05 14:25:14.647000 -03:00
1                    ORA 7445 [kglpnp]                                           1411118              2024-02-09 11:07:11.821000 -03:00
5                    ORA 600 [pfri8#2: plio mismatch ]                           1412102              2024-02-09 14:50:32.299000 -03:00
4                    ORA 7445 [kgiPinObject]                                     1410934              2024-02-12 16:10:55.449000 -03:00
27                   ORA 7445 [pevm_CHK_INST]                                    1420934              2024-02-15 14:54:11.829000 -03:00


adrci> show incident -all
adrci> show incident -mode detail -p "incident_id=176861" 

**********************************************************
INCIDENT INFO RECORD 1
**********************************************************
   INCIDENT_ID                   1420934
   STATUS                        ready
   CREATE_TIME                   2024-02-15 14:54:11.829000 -03:00
   PROBLEM_ID                    27
   CLOSE_TIME                    <NULL>
   FLOOD_CONTROLLED              none
   ERROR_FACILITY                ORA
   ERROR_NUMBER                  7445
   ERROR_ARG1                    pevm_CHK_INST
   ERROR_ARG2                    SIGSEGV
   ERROR_ARG3                    ADDR:0x0
   ERROR_ARG4                    PC:0x133A3996
   ERROR_ARG5                    SI_KERNEL(general_protection)
   ERROR_ARG6                    <NULL>
   ERROR_ARG7                    <NULL>
   ERROR_ARG8                    <NULL>
   ERROR_ARG9                    <NULL>
   ERROR_ARG10                   <NULL>
   ERROR_ARG11                   <NULL>
   ERROR_ARG12                   <NULL>
   SIGNALLING_COMPONENT          PLSQL_Code_Execution
   SIGNALLING_SUBCOMPONENT       <NULL>
   SUSPECT_COMPONENT             <NULL>
   SUSPECT_SUBCOMPONENT          <NULL>
   ECID                          <NULL>
   IMPACTS                       0
   CON_UID                       3004421419
   PROBLEM_KEY                   ORA 7445 [pevm_CHK_INST]
   FIRST_INCIDENT                988075
   FIRSTINC_TIME                 2023-04-25 13:49:55.986000 -03:00
   LAST_INCIDENT                 1420934
   LASTINC_TIME                  2024-02-15 14:54:11.829000 -03:00
   IMPACT1                       0
   IMPACT2                       0
   IMPACT3                       0
   IMPACT4                       0
   KEY_NAME                      PdbName
   KEY_VALUE                     PMTOQUEP
   KEY_NAME                      PQ
   KEY_VALUE                     (16785936, 1708019651)
   KEY_NAME                      Module
   KEY_VALUE                     JDBC Thin Client
   KEY_NAME                      SID
   KEY_VALUE                     7058.31421
   KEY_NAME                      ProcId
   KEY_VALUE                     1519.1153
   KEY_NAME                      Client ProcId
   KEY_VALUE                     oracle@srv-oracle-themacdblite (TNS V1-V3).82941_140360065774592
   KEY_NAME                      Service
   KEY_VALUE                     pmtoquep
   OWNER_ID                      1
   INCIDENT_FILE                 /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/incident/incdir_1420934/THEMALT_ora_82941_i1420934.trc
   OWNER_ID                      1
   INCIDENT_FILE                 /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/trace/THEMALT_ora_82941.trc
1 row fetched


adrci> show trace /u01/app/oracle/diag/rdbms/themalt_gru19s/THEMALT/incident/incdir_1420934/THEMALT_ora_82941_i1420934.trc
Output the results to file: /tmp/utsout_50442_13995_2.ado

        *** 2024-02-15T14:54:11.840431-03:00
        dbkedDefDump(): Starting a non-incident diagnostic dump (flags=0x3, level=3, mask=0x0)
        [TOC00004]
3>       ***** Current SQL Statement for this session (sql_id=6tbg6ydrx9jmm) *****
         begin      dbms_irefstats.purge_stats_mv_rp(in_time => :1, in_objnum => :2, in_retention_period => :3);    end;
