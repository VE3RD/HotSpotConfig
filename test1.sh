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
declare -i GWPage=1
declare -i sectN=1
declare -i indx=1
((GWPage=1))
export GWPage

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

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
        --column-separator \
        --keep-tite \
        --stdout \
        --colors \
        --ascii-lines \
      --radiolist "Select $modes Server:" 22 90 16 \
        "${cmd[@]}" ${options})
exitcode=$?

if [ $exitcode -eq 0 ]; then
pwd=$(dialog \
	--ascii-lines \
	--stdout \
	--inputbox "Enter your Password for $ssid" 20 30 )

	dialog \
        	--ascii-lines \
        	--stdout \
		--title "Selected ESID $ssid" \
        	--infobox "\nResults Ready to Set\n\nESSID = $ssid\nPassw = $pwd" 20 40  



fi


}
ScanWiFi
