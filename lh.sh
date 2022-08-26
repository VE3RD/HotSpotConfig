#!/bin/bash
sudo mount -o remount,rw / > /dev/null
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
cat /etc/lastheard.txt
errorcode=$?
echo -e "\033[44m"
fi



}

##### Main program #########
var=$1

x1=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ "$x1" == "NEW" ]; then
 sudo mount -o remount,rw / > /dev/null
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
        cm=0
        call=$(echo "$LastLine"| cut -d " " -f 9)
fi
if [[ $LastLine == *"network end of transmission"* ]]; then
        cm=1
        call=$(echo "$LastLine"| cut -d " " -f 10)
fi
if [[ $LastLine == *"watchdog has expired"* ]]; then
        cm=2
	dur=$(echo "$LastLine" | grep -o "expired.*" | cut -d " " -f2)
	pl=$(echo "$LastLine" | grep -o "seconds.*" | cut -d " " -f2)
fi

 RFMode=
if [[ $LastLine == *"RF"* ]]; then
       RFMode="R-"
	rfm="RF"
else
	RFMode="N-"
	rfm="NET"
fi

rmode=$(echo "$LastLine" | tr -d "," | cut -d " " -f 4)
rmode="$RFMode$rmode"

call=$(echo "$LastLine" | grep -o "from.*" | cut -d " " -f2)

if [ -z "$call" ]; then 
	## No Callsign - Abort Further Processing
	cm=99
fi

LastGWLine=$(tail -n 1 /var/log/pi-star/DMRGateway-2022* | tail -n 1)

if [[ $LastGWLine == *"NetRX"* ]]; then
   
        GWN=$(echo "$LastGWLine"| cut -d " " -f 6)
fi
if [[ $LastGWLine == *"RFRX"* ]]; then
        
        GWN=$(echo "$LastGWLine"| cut -d " " -f 6)
fi



GetCallInfo
call="$call""  "
call="${call:0:6}"
dd=$(echo "$LastLine" | cut -d " " -f2)
tt=$(echo "$LastLine" | cut -d " " -f3 | cut -d "." -f1)
dt="$dd $tt"



LogStr=
##Active Calls cm=0

   if [ "$cm" -eq 0 ]; then
	if [ "$call" != "$p0call" ]; then	
		tg=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f2)
#		dt=`date '+%Y-%m-%d %H:%M:%S'`
#		dtt=`date '+%H:%M:%S'`
		printf "\033[97m \033[44m"
		echo -e "--Active - $tt $rmode $call $Name, $City, $State, $Country TG:$tg GWNet:$GWN"
#		LogStr="--Active - $tt $rmode $call  $Name, $City, $State, $Country TG:$tg GWNet:$GWN"
		p0call="$call"
		p1call=
		p2call=
		act=1
	fi
   elif [ "$cm" -eq 1 ]; then
#End of Transmission cm=1
	if [ "$call" != "$p1call" ]; then
	#	dt=`date '+%Y-%m-%d %H:%M:%S'`
#M: 2022-08-26 16:01:43.538 DMR Slot 2, received RF voice header from VE3RD to TG 31665
#M: 2022-08-26 16:01:43.959 DMR Slot 2, received RF end of voice transmission from VE3RD to TG 31665, 0.4 seconds, BER: 0.5%, RSSI: -47/-47/-47 dBm

		if [ "$rfm" == "RF" ]; then
			tg=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f2 | tr -d ",")
			dur=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f3)
			ber=$(echo "$LastLine" | grep -o "BER:.*" | cut -d " " -f2)
			pl="N/A"
		else
			tg=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f2 | tr -d ",")
			ber="N/A"
			dur=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f3)
			pl=$(echo "$LastLine" | grep -o "seconds.*" | cut -d " " -f2)

		fi
		printf "\033[33m \033[44m"
		if [ "$act" == 1 ]; then
			tput cuu 1
        	fi
		echo -e "$dt $rmode $call $Name, $City, $State, $Country  Dur:$dur Secs BER:$ber  PL:$pl TG:$tg  GWNet:$GWN"
		LogStr="$dt $rmode $call  $Name, $City, $State, $Country  Dur:$dur Secs BER:$ber  PL:$pl TG:$tg  GWNet:$GWN"
		p1call="$call"
		p0call=
		p2call=
	fi
 	act=0
     elif [ "$cm" -eq 2 ]; then
#Watchdog Timeout cm=2
	if [ "$call" != "$p2call" ]; then
	#	dt=`date '+%Y-%m-%d %H:%M:%S'`
		if [ "$RFMode" == "RF" ]; then
			tg=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f2 | tr -d ",")
			dur=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f3)
			ber=$(echo "$LastLine" | grep -o "BER:.*" | cut -d " " -f2)
			pl=0
		else	
			tg=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f2 | tr -d ",")
			ber=$(echo "$LastLine" | grep -o "BER:.*" | cut -d " " -f2)
			dur=$(echo "$LastLine" | grep -o "TG.*" | cut -d " " -f3)
			pl=$(echo "$LastLine" | grep -o "seconds.*" | cut -d " " -f2)
		fi
		printf "\033[33m \033[44m"
		if [ "$act" == 1 ]; then
			tput cuu 1
        	fi
		echo -e "$dt $rmode $call $Name, $City, $State, $Country  Dur:$dur Secs  PL:$pl TG:$tg  GWNet:$GWN"
		LogStr="$dt $rmode $call  $Name, $City, $State, $Country  Dur:$dur Secs  PL:$pl TG:$tg  GWNet:$GWN"
		p1call="$call"
		p0call=
		p2call=
	fi
 	act=0

    else
        call="NoCall"
	p0call="$call"
	p1call="$call"
	p2call="$call"
	p3call="$call"
   fi

if [ ! -z "$LogStr" ]; then
sudo mount -o remount,rw / > /dev/null
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
