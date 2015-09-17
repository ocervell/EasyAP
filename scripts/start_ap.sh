#!/bin/bash
### START_AP.SH ###

##############################
### HOW TO USE THIS SCRIPT ###
##############################

# ./start_ap.sh <interface_name> 

# e.g: ./start_ap.sh wlan2
# If you encounter an error: check the name of your wlan interface with ifconfig or iwconfig

#############################
### WHAT THIS SCRIPT DOES ###
#############################

# 1. Check the input argument
# 2. Check if wireless interface is valid
# 3. Create a monitor interface with airmon-ng named mon0 (if hardware compatible with Monitor Mode).
# 4. Monitor incoming and outgoing  a with airodump-ng and generate a dump file (.cap).

#Notes: 
 # Generated dump file is in 'logs' folder. 
 # aircrack-ng suite is required.

##############
### SCRIPT ###
##############

#Check input argument
if [ $# -eq 0 ]
  then
    dev=wlan0
    cfg=$EasyAP/hostapd/hostapd_def.conf
    echo "Warning: No interface name supplied. Default interface set to wlan0."
    echo "Warning: No hostapd configuration file supplied. Default configuration file set to hostapd_def.conf."
    phydev=eth0
elif [ $# -eq 1 ]
  then
    dev=$1
    cfg=$1
    phydev=eth0
else
    phydev=eth0
    dev=$1
    cfg=$2
fi

#Check if interface exists
interface=$(iwconfig 2>&1 | grep $dev)
if [ $? -eq 1 ]
  then
    echo "Error: $dev interface doesn't exist. Check your interfaces using iwconfig and pass the correct interface name to the script."
    echo "Usage ./start_ap.sh <interface>"
    exit;
else
    echo "Interface $dev found."
fi

#Configure and start AP
echo ""
echo "===> Start Access Point (AP) <==="

echo ""
echo "Stopping Network Manager to avoid problems..."
sudo service network-manager stop


echo ""
echo "Configuring IP Forwarding ..."
sudo sysctl -w net.ipv4.ip_forward=1
wlanno="${dev: -1}"
sudo rfkill unblock $wlanno

read -p "Are you connected to the network on Ethernet ? (y/N) " yn 
case $yn in
[Yy]* ) echo ""
		echo "Creating bridge between AP interface ($dev) and Internet interface ($phydev) ..."
		sudo ifconfig eth0 down
		sudo ifconfig eth0 0.0.0.0 promisc up
		sudo brctl addbr br0
		sudo brctl addif br0 eth0
		sudo dhclient br0
esac

echo ""
echo "Tweaking hostapd config file ..."
sed -i "s/^interface.*/interface=$1/" $EasyAP/hostapd/hostapd_def.conf

echo ""
echo "Launching hostapd configuration..."
mkdir -p $EasyAP/logs/
sudo hostapd -d $EasyAP/hostapd/hostapd_def.conf 2>&1 | sudo tee $EasyAP/logs/ap_log.txt &
