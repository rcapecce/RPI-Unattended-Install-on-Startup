#!/bin/bash

if [ -z "$1" ]; then
	echo "Format: $0 <path_to_root_rpi_filesystem_sdcard>"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 2
fi

if [ ! -d "$1" ]; then
	echo "Directory not exists: -$1-"
	exit 3
fi

for dir in \
	"$1/etc/systemd/system/multi-user.target.wants" \
	"$1/lib/systemd/system" \
	"$1/opt"
do
	if [ ! -d "$dir" ]; then
		echo "The target directory does not appear to be a root Raspberry Pi OS: -$dir-"
		exit 3
	fi
done

cp rpi-do-on-start.sh $1/opt

cd $1

cat > lib/systemd/system/rpi-do-on-start.service << EOL
[Unit]
Description=RPI Unattended Install on Startup

[Service]
ExecStart=/opt/rpi-do-on-start-launcher.sh
Type=idle

[Install]
WantedBy=multi-user.target

EOL

ln -s /lib/systemd/system/rpi-do-on-start.service etc/systemd/system/multi-user.target.wants

cat > opt/rpi-do-on-start-launcher.sh << EOL
#!/bin/bash

systemctl disable rpi-do-on-start.service
rm /lib/systemd/system/rpi-do-on-start.service

/opt/rpi-do-on-start.sh
rm /opt/rpi-do-on-start-launcher.sh
rm /opt/rpi-do-on-start.sh

EOL

chmod +x opt/rpi-do-on-start-launcher.sh
chmod +x opt/rpi-do-on-start.sh
