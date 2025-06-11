#########################
# Configurar HUGEPAGES:
#########################

#coletar informacao do tamanho de pagina
$ grep Hugepagesize /proc/meminfo
Hugepagesize:       2048 kB

#coletar informacao do tamanho da SGa
SQL> show parameter sga_max_size
sga_max_size => 40G

#transformar tudo para MB (exemplo)
2048KB / 1024 -> 2MB
40GB * 1024 -> 40960MB

#calular valor de hugepages
nr_hugepages = SGA (MB) / Tamanho da Página (MB)
nr_hugepages = 40960 / 2

#definir hugepages
$ echo 'vm.nr_hugepages=20484' >> /etc/sysctl.conf
$ systemctl -p

################################
# shutdown ORACLE && reboot SO
################################

#validar alteração
$ grep Huge /proc/meminfo
$ grep -A2 PAGESIZE alert.log



SQL> show parameters use_large_pages
SQL> alter system set  use_large_pages = only scope=spfile; 
alter system set  use_large_pages = true scope=spfile; 