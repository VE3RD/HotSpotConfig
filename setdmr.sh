#!/bin/bash
############################################################
#  This script will automate the process of                #
#  Switching DMR Servers     		                   #
#                                                          #
#  VE3RD                              Created 2022/07/20   #
############################################################
#set -o errexit
#set -o pipefail
#set -e

mm=$(pgrep MMDVMHost)
dmrgw=$(pgrep DMRGateway)
p25gw=$(pgrep P25Gateway)
ysf2p25=$(pgrep ysf2p25)
ysfgw=$(pgrep ysfgateway)


function clearall(){
	sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\10/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Enable=\).*/\10/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/P25]/s/\(Enable=\).*/\10/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/P25 Network]/s/\(Enable=\).*/\10/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Network]/s/\(Enable=\).*/\10/m;P;d' /etc/ysfgateway
	sudo sed -i '/^\[/h;G;/Network]/s/\(Enable=\).*/\10/m;P;d' /etc/ysf2p25
}

function currentserver(){
	Name=$(sed -nr "/^\[DMR Network\]/ { :l /^Name[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/mmdvmhost)
	echo "Current Server = $Name"
}

function badparam() {
	echo "No Server String supplied"
	echo "Options = TGIF, MNET, DMRGW, P25, STATUS"
	currentserver
  	exit
}


if [ -z "$1" ]; then
  badparam
fi

var="$1" 
VARIABLE=$(echo "$var" | tr '[:lower:]' '[:upper:]') 

Server="$VARIABLE"

if [ "$VARIABLE" == "MNET" ]; then
	Name="MNET_Network"
	Addr="mnet.hopto.org"
	Pwd=$(sed -nr "/^\[MNET\]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/passwords)
	clearall
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Type=\).*/\1Direct/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	if [ "$dmrg" ]; then sudo pkill DMRGateway ; fi
	if [ "$p25gw" ]; then sudo pkill P25Gateway ; fi
elif [ "$VARIABLE" == "TGIF" ]; then
	Name="TGIF_Network"
	Addr="tgif.network"
	clearall
	Pwd=$(sed -nr "/^\[TGIF\]/ { :l /^Password[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" /etc/passwords)
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Type=\).*/\1Direct/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	if [ "$dmrg" ]; then sudo pkill DMRGateway ; fi
	if [ "$p25gw" ]; then sudo pkill P25Gateway ; fi

elif [ "$VARIABLE" == "DMRGW" ]; then
	Name="DMRGateway"
	Addr="127.0.0.1"
	Pwd="None"
	clearall
	sudo sed -i '/^\[/h;G;/Info]/s/\(Type=\).*/\1Gateway/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1439025000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	if [ "$p25gw" ]; then sudo pkill P25Gateway ; fi

elif [ "$VARIABLE" == "P25" ]; then
	Name="P25-MNET"
	Addr="mnet.hopto.org"
	Pwd="None"
	clearall
	sudo sed -i '/^\[/h;G;/Info]/s/\(TXFrequency=\).*/\1432700000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/Info]/s/\(RXFrequency=\).*/\1432700000/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Type=\).*/\1Gateway/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/P25]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	sudo sed -i '/^\[/h;G;/P25 Network]/s/\(Enable=\).*/\11/m;P;d' /etc/mmdvmhost
	echo P25-A
	sudo p25gateway.service restart
	if [ "$dmrg" ]; then sudo pkill DMRGateway ; fi
	
elif [ "$VARIABLE" == "STATUS" ]; then
	currentserver
else
  badparam

fi

sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Name=\).*/\1'"$Name"'/m;P;d' /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Address=\).*/\1'"$Addr"'/m;P;d' /etc/mmdvmhost
sudo sed -i '/^\[/h;G;/DMR Network]/s/\(Password=\).*/\1'"$Pwd"'/m;P;d' /etc/mmdvmhost
 
echo "Sleeping 5 Seconds "
sleep 5
currentserver
echo "restarting MMDVMHost"
sudo mmdvmhost.service restart
