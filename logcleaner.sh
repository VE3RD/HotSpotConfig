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

sudo mount -o remount,rw / > /dev/null

sudo find /var/log/pi-star/ -mindepth 1 -mmin +1442 -exec rm -rf {} \;



