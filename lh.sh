#!/bin/bash

Cyan='\033[0;36m'
Yellow='\033[0;33m'

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
echo "Use Space Bar to Exit"
echo ""



while [ true ]
do

LastLine=$(tail -n 1 /var/log/pi-star/MMDVM-2022*)

str="voice header"

if [[ $LastLine == *"voice header"* ]]; then
	cm=0
 	call=$(echo "$LastLine"| cut -d " " -f 12)
fi
if [[ $LastLine == *"voice transmission"* ]]; then
	cm=1
 	call=$(echo "$LastLine"| cut -d " " -f 14)
fi
 


#if [ "$call" == "$pcall" ]; then
#  j=j
#else

#    echo "CM = $cm"

   if [ "$cm" == 1 ]; then
	if [ "$call" != "$p1call" ]; then
		call=$(echo "$LastLine" | cut -d " " -f 14)
		dur=$(echo "$LastLine" | cut -d " " -f 18)
		pl=$(echo "$LastLine" | cut -d " " -f 20)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[32m$dt $call  $Name  $City  $State  $Country Dur: $dur  PL: $pl\033[0m"
		p1call="$call"
	fi
   elif [ "$cm" == 0 ]; then
	if [ "$call" != "$p0call" ]; then	
		call=$(echo "$LastLine" | cut -d " " -f 12)
		GetCallInfo
		dt=`date '+%Y-%m-%d %H:%M:%S'`
		echo -e "\033[36m---Active - $dt $call  $Name  $City  $State  $Country \033[0m"
		p0call="$call"
	fi
    else
        call="NoCall"
	p0call="$call"
	p1call="$call"
   fi

sleep 0.1
if read -n1 -t1 -r -s x; then
        /bin/bash hsconfig.sh
    fi

done
