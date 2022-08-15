#!/bin/bash

Cyan='\033[0;36m'
Yellow='\033[0;33m'
export NCURSES_NO_UTF8_ACS=1
clear
echo -e "\e[1;97;44m"



function GetCallInfo () {

  cline=$(grep ",$call," /usr/local/etc/stripped.csv | tail -n 1)

  Name=$(echo "$cline" | cut -d "," -f 3)
  City=$(echo "$cline" | cut -d "," -f 5)
  State=$(echo "$cline" | cut -d "," -f 6)
  Country=$(echo "$cline" | cut -d "," -f 7)
}


##### Main program #########

pcall=""
call=""

clear


echo "Use 'Q' or 'E' to EXIT or Space Bar to Return to Hot Spot Configure "
echo ""
if [ -f /etc/LastHeard.txt ]; then

echo -e "\033[1;97;45m" 
echo "Reading Log File"
cat /etc/LastHeard.txt
echo -e "\033[1;97;44m"
fi


while [ true ]
do

LastLine=$(tail -n 1 /var/log/pi-star/MMDVM-2022* | tail -n 1)

str="voice header"
##DMR
if [[ $LastLine == *"voice header"* ]]; then
	cm=0
 	call=$(echo "$LastLine"| cut -d " " -f 12)
fi
if [[ $LastLine == *"voice transmission"* ]]; then
	cm=1
 	call=$(echo "$LastLine"| cut -d " " -f 14)
fi
##P25
if [[ $LastLine == *"network transmission"* ]]; then
        cm=3
        call=$(echo "$LastLine"| cut -d " " -f 14)
fi

if [[ $LastLine == *"end of transmission"* ]]; then
        cm=4
        call=$(echo "$LastLine"| cut -d " " -f 14)
fi
 


#if [ "$call" == "$pcall" ]; then
#  j=j
#else

#    echo "CM = $cm"
rmode=$(echo "$LastLine" | cut -d " " -f 4)
LogStr=

   if [ "$cm" == 0 ]; then
	if [ "$call" != "$p0call" ]; then	
		call=$(echo "$LastLine" | cut -d " " -f 12)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[36m\033[1;97;44m ---Active - $dt $rmode $call  $Name  $City  $State  $Country \033[0m"
		p0call="$call"
	fi
   elif [ "$cm" == 1 ]; then

	if [ "$call" != "$p1call" ]; then
		call=$(echo "$LastLine" | cut -d " " -f 14)
		dur=$(echo "$LastLine" | cut -d " " -f 18)
		pl=$(echo "$LastLine" | cut -d " " -f 20)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[32m\033[1;97;44m$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl\033[0m"
		LogStr="$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl"
		p1call="$call"
	fi
 

   elif [ "$cm" == 2 ]; then

	if [ "$call" != "$p2call" ]; then	
		call=$(echo "$LastLine" | cut -d " " -f 9)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[36m\033[1;97;44m ---Active - $dt $rmode $call  $Name  $City  $State  $Country \033[0m"
		p2call="$call"
	fi
   elif [ "$cm" == 3 ]; then
	if [ "$call" != "$p3call" ]; then
		call=$(echo "$LastLine" | cut -d " " -f 10)
		dur=$(echo "$LastLine" | cut -d " " -f 14)
		pl=$(echo "$LastLine" | cut -d " " -f 16)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[32m\033[1;97;44m$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl\033[0m"
		LogStr="$dt $rmode $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl"
		p3call="$call"
	fi
    else
        call="NoCall"
	p0call="$call"
	p1call="$call"
	p2call="$call"
	p3call="$call"
   fi

if [ ! -z "$LogStr" ]; then
  echo "$LogStr" >> /etc/LastHeard.txt
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
