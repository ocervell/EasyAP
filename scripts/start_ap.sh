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
elif [ $# -eq 1 ]
  then
    dev=$1
    cfg=$1
else
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

echo "Stopping Network Manager to avoid problems..."
sudo service network-manager stop

echo "Configuring /etc/net/network/interfaces ..."
interfaces=/etc/network/interfaces
if ! grep -q "$dev" "$interfaces"
then
      echo "auto $dev
            iface $dev inet static
            hostapd $cfg
      	    address 10.0.0.1
      	    netmask 255.255.255.0" | sudo tee --append $interfaces
fi

echo ""
echo "Configuring DNS relay ..."
dnsconf=/etc/dnsmasq.conf
if ! grep -q "$dev" "$dnsconf"
then
      echo "no-resolv
	    interface=lo,$dev
            no-dhcp-interface=lo
            dhcp-range=10.0.0.3,10.0.0.20,12h
	    server=8.8.8.8
	    server=8.8.8.4" | sudo tee --append $dnsconf
fi

echo ""
echo "Configuring /etc/sysctl.conf ..."
sysctl=/etc/sysctl.conf
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' $sysctl

#echo ""
#echo "Configuring DHCP server ..."
#dhcp=/etc/dhcp/dhcpd.conf

#if [ ! -e "$dhcp" ] ; then
#	sudo touch $dhcp
#	echo "subnet 10.10.0.0 netmask 255.255.255.0 {
#       range 10.10.0.25 10.10.0.50;
#  	      option domain-name-servers 8.8.4.4;
#      	      option routers 10.10.0.1;
#      	      interface $dev;
#      	      }" | sudo tee --append $dhcp
#fi;

#echo ""
#echo "Restarting DHCP ..."
#sudo ifconfig $dev 10.0.0.1
#sudo /etc/init.d/isc-dhcp-server restart

echo ""
echo "Configuring NAT & IP Forwarding ..."
echo "1" | sudo tee --append /proc/sys/net/ipv4/ip_forward
wlanno="${dev: -1}"
echo ""
echo $wlanno
echo ""
sudo rfkill unblock $wlanno

#Initial wifi interface configuration
sudo ifconfig $dev up 10.0.0.1 netmask 255.255.255.0
sleep 2
 
###########Start dnsmasq, modify if required##########
if [ -z "$(ps -e | grep dnsmasq)" ]
then
 sudo dnsmasq
fi
###########
 
#Enable NAT
sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --delete-chain
sudo iptables --table nat --delete-chain
sudo iptables --table nat --append POSTROUTING --out-interface wlan0 -j MASQUERADE
sudo iptables --append FORWARD --in-interface $dev -j ACCEPT
 
#Thanks to lorenzo
#Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
sudo sysctl -w net.ipv4.ip_forward=1

echo ""
echo "Tweaking hostapd config file ..."
sed -i "s/^interface.*/interface=$1/" $EasyAP/hostapd/hostapd_def.conf

echo ""
echo "Launching hostapd configuration..."
mkdir -p $EasyAP/logs/
sudo hostapd -d $EasyAP/hostapd/hostapd_def.conf 2>&1 | sudo tee $EasyAP/logs/ap_log.txt &
