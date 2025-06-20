#!/bin/bash
##############################################################################
# Nome: asm_physical_disk.sh
# Descrição: Identifica os discos 
#            
# Autor: DBA Bruno Bernardes
# Versão: 1.0
# Data: 2025-04-25
# Uso: Execute como root -> sh asm_physical_disk.sh [parametro]
# Varibables:
# - ASMLIB_DISK: disk name in ASMLIB
# - ASM_DISK: disk name in ASM
# - DEVICE: physical disk name
# Referência: https://asmsupportguy.blogspot.com/2010/05/how-to-map-asmlib-disk-to-device-name.html
##############################################################################
if [ -z "$GRID_HOME" ]; then
 GRID_HOME=`cat /etc/oratab  | grep ^+ASM | awk -F":" '{print $2}'`
fi
for ASMLIB_DISK in `ls /dev/oracleasm/disks/*`
  do
    echo ""
    ASM_DISK=`$GRID_HOME/bin/kfed read $ASMLIB_DISK | grep dskname | tr -s ' '| cut -f2 -d' '`
    bigsmall=`ls -l $ASMLIB_DISK | tr -s ' ' | cut -f5,6 -d' '`
    device=`ls -l /dev/ | tr -s ' ' | grep -w "$bigsmall" | cut -f10 -d' '`
    echo "ASMLIB disk name : $ASMLIB_DISK"
    echo "ASM_DISK name : $ASM_DISK"
    echo "Physical disk device : /dev/$device"
done
echo ""
