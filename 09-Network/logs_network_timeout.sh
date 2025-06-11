
#config
vim $ORACLE_HOME/network/admin/sqlnet.ora
vim $ORACLE_HOME/network/admin/s

#Procura enderço dos erros reportados no ALERT.LOG (DIAG_ADR_ENABLED=ON)
tail -999f /u01/app/oracle/diag/rdbms/tjac/tjac/trace/alert_tjac.log
cat /u01/app/oracle/diag/rdbms/tjac/tjac/trace/alert_tjac.log |grep "Client address:" -B12
cat /u01/app/oracle/diag/rdbms/tjac/tjac/trace/alert_tjac.log |grep "Client address:" -B15 |grep -e 'Time\|Client'

#Procura tempo dos timetouts reportados SQLENT.LOG (DIAG_ADR_ENABLED=OFF)
cat $ORACLE_HOME/network/log/sqlnet.log |grep TNS-00505 -B7 |grep Time

#Trace do Listener: /u01/app/oracle/diag/tnslsnr/THEMA-ORACLE/listener/trace
192.168.61.67 -> (CONNECT_DATA=(SID=tjac)(CID=(PROGRAM=ThemaERP-JAVA)(HOST=__jdbc__)(USER=root))) 
