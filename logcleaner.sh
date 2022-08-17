#!/bin/bash
############################################################
#  This script will clean out old log files                #
#                                                          #
#                                                          #
#                                                          #
#  VE3RD                              Created 2022/08/17   #
############################################################
#set -o errexit
#set -o pipefail
#set -e

# Get newest file
sudo mount -o remount,rw / > /dev/null
NewF=$(ls /var/log/pi-star/*.log | tail  -n 1)

MMDVM_F=$(date -r `ls /var/log/pi-star/MMDVM-202* | tail -n 1`)
DMRG_F=$(date -r `ls /var/log/pi-star/DMRGateway-202* | tail -n 1`)
YSF_F=$(date -r `ls /var/log/pi-star/YSF-202* | tail -n 1`)
NXDN_F=$(date -r `ls /var/log/pi-star/NXDN-202* | tail -n 1`)
P25_F=$(date -r `ls /var/log/pi-star/P25-202* | tail -n 1`)




echo "$NewF"

test "$NewF" "-" 2
echo "$test"
exit

def remove_head_parts(s, delim, n):
    return s.split(delim, n)[n]

NDateStr1=$(echo "$NewF" |cut -d "." -f 1 ) 
echo "$NDateStr1"
value=${NDateStr2#*-}
echo "$value"
exit
logfiles=$(ls /var/log/pi-star/*.log)



