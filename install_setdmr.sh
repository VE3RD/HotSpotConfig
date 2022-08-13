#!/bin/bash
#########################################################
# This script will install the password file for 	#
# the setdmr.sh script				 	#
#						 	#
# VE3RD					2022-07-22	#
#########################################################
set -o errexit
set -o pipefail
set -e

if [ ! -f "/etc/passwords" ]; then 
	cp ./passwords /etc/
#echo password file copied to /etc
fi
nano /etc/passwords
