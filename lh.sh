#!/bin/bash

var1=$1

Cyan='\033[0;36m'
Yellow='\033[0;33m'
export NCURSES_NO_UTF8_ACS=1
clear
echo -e "\e[1;97;44m"
cm=[0]
declare -i cm=0

function GetCallInfo () {

  cline=$(grep ",$call," /usr/local/etc/stripped.csv | tail -n 1)

  Name=$(echo "$cline" | cut -d "," -f 3)
  City=$(echo "$cline" | cut -d "," -f 5)
  State=$(echo "$cline" | cut -d "," -f 6)
  Country=$(echo "$cline" | cut -d "," -f 7)
}

function CheckLog(){
if [ -f /etc/lastheard.txt ]; then

echo -e "\033[45m" 
echo "Reading Log File"
cat /etc/LastHeard.txt
#dialog --title "Last Heard Log File" --clear --ascii-lines --tailbox /etc/LastHeard.txt 20 0
errorcode=$?
echo -e "\033[44m"
fi



}

##### Main program #########
var=$1

x1=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ "$x1" == "NEW" ]; then
 sudo rm /etc/lastheard.txt
fi

pcall=""
call=""

clear


echo "Use 'Q' or 'E' to EXIT or Space Bar to Return to Hot Spot Configure "
echo ""
CheckLog


while [ true ]
do

LastLine=$(tail -n 1 /var/log/pi-star/MMDVM-2022* | tail -n 1)

str="voice header"
##DMR
if [[ $LastLine == *"network voice header"* ]]; then
	cm=0
 	call=$(echo "$LastLine"| cut -d " " -f 12)
fi
if [[ $LastLine == *"network end of voice"* ]]; then
	cm=1
 	call=$(echo "$LastLine"| cut -d " " -f 14)
fi
##P25
if [[ $LastLine == *"network transmission"* ]]; then
        cm=2
        call=$(echo "$LastLine"| cut -d " " -f 9)
fi

if [[ $LastLine == *"network end of transmission"* ]]; then
        cm=3
        call=$(echo "$LastLine"| cut -d " " -f 10)
fi
 


#if [ "$call" == "$pcall" ]; then
#  j=j
#else

#    echo "CM = $cm"
rmode=$(echo "$LastLine" | tr -d "," | cut -d " " -f 4)
LogStr=

   if [ "$cm" -eq 0 ]; then
	if [ "$call" != "$p0call" ]; then	
		call=$(echo "$LastLine" | cut -d " " -f 12)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[33m\033[44m ---Active - $dt $rmode $call  $Name  $City  $State  $Country"
		p0call="$call"
		p1call=
		p2call=
		p3call=
	fi
   elif [ "$cm" -eq 1 ]; then

	if [ "$call" != "$p1call" ]; then
		call=$(echo "$LastLine" | cut -d " " -f 14)
		dur=$(echo "$LastLine" | cut -d " " -f 18)
		pl=$(echo "$LastLine" | cut -d " " -f 20)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		printf "\033[97m \033[44m"
		echo  "$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL:$pl"
		LogStr="$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl"
		p1call="$call"
		p0call=
		p2call=
		p3call=
	fi
 

   elif [ $cm -eq 2 ]; then

	if [[ "$call" != "$p2call" ]]; then	
		call=$(echo "$LastLine" | cut -d " " -f 9)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[33m\033[44m ---Active - $dt $rmode $call  $Name  $City  $State  $Country "
		p2call="$call"
		p0call=
		p1call=
		p3call=
	fi

   elif [ $cm -eq 3 ]; then
	if [[ "$call" != "$p3call" ]]; then
		call=$(echo "$LastLine" | cut -d " " -f 10)
		dur=$(echo "$LastLine" | cut -d " " -f 14)
		pl=$(echo "$LastLine" | cut -d " " -f 16)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
                printf "\033[97m \033[44m"
                echo  "$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL:$pl"
		LogStr="$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl"
		p3call="$call"
		p0call=
		p2call=
		p1call=

	fi
    else
        call="NoCall"
	p0call="$call"
	p1call="$call"
	p2call="$call"
	p3call="$call"
   fi

if [ ! -z "$LogStr" ]; then
  echo "$LogStr" >> /etc/lastheard.txt
fi

sleep 0.1
if read -n1 -t1 -r -s x; then

	x1=$(echo "$x" | tr '[:lower:]' '[:upper:]')
        clear
	if [ "$x1" = "Q" ] || [ "$x1" = "E" ]; then
		exit
	fi
        /bin/bash hsconfig.sh
    fi

done
