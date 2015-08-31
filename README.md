#**EASYAP**
####Turn a WLAN interface to an Access Point.
####Add a Monitor interface and monitor incoming and outgoing packets.
####Enable debugging and tracing for ath9k_htc driver, mac80211 framework.

##**Presentation**

* EasyAP contains all the tools to turn an hardware device into an Access Point.
* EasyAP also sets up a monitoring interface and generate dump files using the aircrack-ng suite. Dump files are generated and can be analyzed with wireshark.
* EasyAP enables debugging and tracing for Atheros drivers, if your kernel has been compiled with the right options.  
* EasyAP can also enable PSM (Power Save Mode) if your wireless driver supports it.

**Note:** The wireless card of the device has to be compatible with AP MODE and MONITOR MODE. If it is not, the scripts won't work. It is usually not the case for smartphone and you might have to add an USB Wireless Card that supports those modes.

##**What's left to do**
* Debugging and tracing activation for other drivers than ath9k_htc.
* Improving logs
* Create a Command Line Interface (CLI).
* Create a Graphical User Interface (GUI).

##**Getting Started**

**1. Initial configuration**

`source configure`  
* exports a global variable in your ~/.bashrc file.
* installs all necessary tools using apt-get install.

**2. Play with the scripts**

* In the 'scripts' folder, you will find shell scripts that will make your life easy.
* Scripts behaviour is detailed in 'manual.txt' file, along with instructions.

##**Project Tree**

Once you're done with the configuration and initialization, you will
get a similar tree than the one showed below (only important files are shown).

```

EasyAP
├── README.md           #GitHub ReadMe file
├── manual.txt          #manual for scripts and commands
├── start.sh            #start AP, start monitoring and turn Power Save on
├── stop.sh             #stop AP, stop monitoring and turn Power Save off
├── cleanup.sh          #delete all archived log (clear 'archive' folder)
│
├── archive             #Old logs
│
├── hostapd		#Hostapd configuration files
│   └── hostapd_def.conf    #hostapd AP default config
│
├── logs                #Airodump logs, ap log and ath9k_htc functions trace
│   ├── ap_log.txt          #log of Access Point actions
│   ├── ath9k_trace_log.txt #trace of functions calls inside ath9k_htc driver
│   ├── beacons.cap-01.cap  #dump file to be open with Wireshark
│   ├── beacons.cap-01.csv
│   ├── beacons.cap-01.kismet.csv
│   └── beacons.cap-01.kismet.netxml
│
└── scripts             #Scripts to on/off AP (hostapd), monitor, turn on/off PSM
    ├── monitor_ap.sh       #start a monitor interface and record packets
    ├── psm_off.sh          #turn off psm
    ├── psm_on.sh           #turn on psm
    ├── start_ap.sh         #start AP mode
    └── stop_ap.sh          #stop AP mode
