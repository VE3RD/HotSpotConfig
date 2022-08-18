#!/bin/bash
############################################################
#  This script will scan and Set WIFI                      #
#                                                          #
#  VE3RD                              Created 2022/08/01   #
############################################################
#set -o errexit
#set -o pipefail
#set -e
trap ctrl_c INT

function ctrl_c() {
  exit
}

export NCURSES_NO_UTF8_ACS=1
clear
echo -e "\e[1;97;44m"
tput setab 4
clear

##Set default colors
sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc
sudo sed -i '/tag_color = /c\tag_color = (YELLOW,BLUE,OFF)' ~/.dialogrc
sudo sed -i '/tag_key_color = /c\tag_key_color = (YELLOW,BLUE,OFF)' ~/.dialogrc
sudo sed -i '/tag_key_selected_color = /c\tag_key_selected_color = (YELLOW,BLUE,ON)' ~/.dialogrc

Mode="RO"
CallSign=""
DID=""

RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"

mode=$1
if [ -z "$mode" ]; then
mode="RO"
fi

#########  Start of Functions  ################
function ScanWiFi(){

options=$( iwlist wlan0 scan |grep -wv \x00 | grep ESSID | cut -d ":" -f2 |  awk '{print $1, FNR, "N/A"}')
ssid=$(dialog \
	--title "WiFi ESSID Selector" \
	--ascii-lines \
        --stdout \
      --radiolist "Select ESSID from the following List: MODE=$mode" 22 90 16 \
        "${cmd[@]}" ${options})
exitcode=$?

if [ $exitcode -eq 0 ]; then
pwd=$(dialog \
	--ascii-lines \
	--stdout \
	--inputbox "Enter your Password for $ssid" 20 30 )

	wificmd="sudo nmcli dev wifi connect ""$ssid"" password ""$pwd"
	
	dialog \
        	--ascii-lines \
        	--stdout \
		--title "Selected ESID $ssid   MODE = $Mode" \
        	--infobox "\nResults Ready to Set\n\nESSID = $ssid\nPassw = $pwd\n\n Command= $wificmd" 20 80  

	if [ "$Mode" == "RW" ];then

		sudo nmcli dev wifi connect "$ssid" password "$pwd"
	fi
fi


}
ScanWiFi
