# Swap 
#
#

#Verificar valor atual de SWAPPINESS
$ sysctl vm.swappiness
vm.swappiness = 60    # default 


#Configurar permanente
vim /etc/sysctl.conf
--> vm.swappiness = 10
sysctl -p


#Verificar valor em utilização
cat /proc/sys/vm/swappiness


#Restart do SWAP 
free -m
swapoff -a 
free -m
swapon -a
free -m

