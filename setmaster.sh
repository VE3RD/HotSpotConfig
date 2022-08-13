#!/bin/bash

DIR="/var"
F1=""
modes=""
d1="/usr/local/etc/"
indx=0

function SelectMode(){
((indx++))

smode=$(dialog \
	--ascii-lines \
	--keep-tite \
	--clear \
	--stdout \
	--title "Mode Selector" \
	--radiolist "Select Mode $indx"  20 30 20 \
	1 "D-Star" OFF \
	2 "DMR" ON \
	3 "YSF" OFF \
	4 "NXDN" OFF \
	5 "P25" OFF )

exitcode=$?

if [ $exitcode -eq 1 ]; then 
	exit
fi
F1=""
F2=""
F3=""
case "$smode" in
	1) 	F1="/usr/local/etc/DPlus_Hosts.txt"
		F2="/usr/local/etc/DExtra_Hosts.txt"
		F3="/usr/local/etc/DCS_Hosts.txt"
		modes="D-Star"
	;;
	2) F1="/usr/local/etc/DMR_Hosts.txt" ; modes="DMR"
	;;
	3) F1="/usr/local/etc/YSFHosts.txt"
	   F2="/usr/local/etc/FCSHosts.txt2" 
	   modes="YSF"
	;;
	4) F1="/usr/local/etc/NXDNHosts.txt"
	   F2="/usr/local/etc/NXDNHostsLocal.txt"
	   modes="NXDN"
	;;
	5) F1="/usr/local/etc/P25Hosts.txt"
           F2="/usr/local/etc/P25HostsLocal.txt"
	    modes="P25"
	;;
esac

if [ -z "$smode" ]; then
  SelectMode
fi

SearchBox

}

function SearchBox(){
sbox=$(dialog \
        --ascii-lines \
	--clear \
        --stdout \
        --title "Mode Selector" \
        --inputbox "Enter $modes Search Text $indx"  20 30  )

exitcode=$?

if [ $exitcode -eq 1 ]; then
        exit
fi

if [ -z "$sbox" ]; then
  SearchBox
fi

#echo "Searching for $sbox in $F1"

Svr=$(grep -E "$sbox" $F1 $F2 $F3 |sed -e '/^#.*/d' | tr -s "\t" | tr "\t" ";" |  awk '{print $1, FNR, "N/A"}' | cut -d ":" -f2)
echo "Test2 = $Svr"


##Svr=$(echo "$Svr" | awk '{print $1, FNR, "off"}')


choose

}

#Select master from a list of possible items
function choose () {
 options=$Svr
  status=OFF

cmd=$(dialog --title "Master Server Selector" \
	--column-separator \
	--keep-tite \
	--stdout \
	--colors \
	--ascii-lines \
      --radiolist "Select $modes Server:" 22 90 16 \
 	"${cmd[@]}" ${options})

exitcode=$?
options=

if [ $indx -gt 2 ]; then
	exit
fi


if [ -z "$cmd" ]; then
  exit
fi

if [ $exitcode -eq 1 ]; then

  SelectMode
fi
if [ $exitcode -eq 255 ]; then
  SelectMode
fi

echo "Selected = $cmd"

Parse 

}




## Check and parse out the selected Master
function Parse () {
      choice="$cmd"


  if [ -z "$cmd" ]; then
          dialog --ascii-lines --clear --title "Parse Function" --msgbox "No Selection Found" 3 70
	exit

  fi

  echo "Choice = $choice   Mode = $smode    CMD: $cmd"
     case "$smode" in
	1) #D-STAR
  	  SvrRoom=$(echo "$choice" | cut -d ";" -f1)
  	  SvrAddr=$(echo "$choice" | cut -d ";" -f2)
          dstr="MODE = $modes\nRoom: $SvrRoom \nAddress: $SvrAddr"
	;;
	2) #DMR
  	  SvrName=$(echo "$choice" | cut -d ";" -f1)
  	  SvrAddr=$(echo "$choice" | cut -d ";" -f3)
  	  SvrPwd=$(echo "$choice" | cut -d ";" -f4)
  	  SvrPort=$(echo "$choice" | cut -d ";" -f5)
          dstr="MODE = $modes\nName: $SvrName \nAddr: $SvrAddr\nPasswd: $SvrPwd \nPort: $SvrPort"
	;;
	3) #YSF
  	  SvrTG=$(echo "$choice" | cut -d ";" -f1)
  	  SvrName=$(echo "$choice" | cut -d ";" -f3)
  	  SvrAddress=$(echo "$choice" | cut -d ";" -f4)
  	  SvrPort=$(echo "$choice" | cut -d ";" -f5)
          dstr="MODE = $modes\nTG: $SvrTG \nName: $SvrName \nAddr: $SvrAddress \nPort: $SvrPort"
	;;
	4) #NXDN
  	  SvrTG=$(echo "$choice" | cut -d ";" -f1)
  	  SvrAddr=$(echo "$choice" | cut -d ";" -f2)
  	  SvrPort=$(echo "$choice" | cut -d ";" -f3)
	dstr="MODE = $modes\nTG: $SvrTG \nAddr: $SvrAddr \nPort: $SvrPort"
 	;;
	5)	#P25
  	  SvrTG=$(echo "$choice" | cut -f1)
  	  SvrAddr=$(echo "$choice" | cut -f2)
  	  SvrPort=$(echo "$choice" | cut -f3)
	dstr="MODE = $modes\nTG: $SvrTG \nAddr: $SvrAddr \nPort: $SvrPort"

	;;
     esac

 dialog --ascii-lines --clear --title "Selected $modes Server Detail" --msgbox "$dstr" 10 70


clear

}

SelectMode
/bin/bash /home/pi-star/configurator.sh

#exit
##cho
#exit
