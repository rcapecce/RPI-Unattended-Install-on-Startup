#!/bin/bash
# Put here your script content in this file

# ==============================================================================
# The example script below allows you to create a remote access only by starting the microsd (just installed)
# * Connect to a wifi network
# * Set a static IP
# * Enable the remote access via SSH

# === Wireless Configuration
# == If any of these variables is not set, the WiFi will not be set ===
# SCID of my Wireless network
wifi_scid=
# Wireless Password
wifi_pwd=

# === Wireless static IP
# == If I need a static IP instead of dhcp
# == If any of these variables is not set, the static IP will not be set
# IP / Mask - e.g. 192.168.1.10/24
lan_ip=
# Gateway - e.g. 192.168.1.1
lan_gw=
# DNS
lan_dns=8.8.8.8

if [[ ! -z "$wifi_scid" ]] && [[ ! -z "$wifi_pwd" ]]; then
	echo "Setting Wireless Configuration"
	wpa_passphrase $wifi_scid $wifi_pwd | sed '/#psk=/d' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo "Unlocking wireless wlan0 device"
	sudo rfkill unblock 0
	echo "Setted Wireless Configuration"
fi

if [[ ! -z $lan_ip ]] && [[ ! -z $lan_gw ]] && [[ ! -z $lan_dns ]]; then
	echo "Setting Static IP Configuration"
	cat >> /etc/dhcpcd.conf << EOL

interface wlan0
static ip_address=$lan_ip
static routers=$lan_gw
static domain_name_server=$lan_dns

EOL
	echo "Setted Static IP Configuration"
fi

wpa_cli -i wlan0 reconfigure

systemctl start ssh.service
systemctl enable ssh.service

# End example
# ==============================================================================
