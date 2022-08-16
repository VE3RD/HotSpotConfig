#!/bin/bash
###############################################################
# Support for Nextion Screen to format ESSID list for screen  #
#                                                             #
# VE3RD                                           2022-08-16  #
###############################################################


#iwlist wlan0 scan | grep 'ESSID' | sed 's/.*ESSID:"\(.*\)".*/\1/g' | tr " " "\n"|sed -n '1p'
#main=$(iwlist wlan0 scan | grep 'ESSID' | sed 's/.*ESSID:"\(.*\)".*/\1/g')
main=$(sudo iw dev wlan0 scan | grep SSID: | cut -d " " -f2)
#echo "$main"

p1=$(echo "$main" | sed -n '1p')
p2=$(echo "$main" | sed -n '2p')
p3=$(echo "$main" | sed -n '3p')
p4=$(echo "$main" | sed -n '4p')
p5=$(echo "$main" | sed -n '5p')

p6=$(echo "$main" | sed -n '6p')
p7=$(echo "$main" | sed -n '7p')
p8=$(echo "$main" | sed -n '8p')
p9=$(echo "$main" | sed -n '9p')
p10=$(echo "$main" | sed -n '10p')

echo -e "$p1\n$p2\n$p3\n$p4\n$p5\n$p6\n$p7\n$p8\n$p9\n$p10"

