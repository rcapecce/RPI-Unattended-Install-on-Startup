# RPI Unattended Install on Startup

This script allows you to run any script without having to login into the Raspberry, just by placing this script in the filesystem of the respective microsd.

You can copy the Raspberry Pi OS image to a microsd, and mounting your script in the root filesystem with this project, you will not need to login to the Raspberry Pi to do any initial configuration, you can have your own unattended configuration script to config your Raspberry Pi and you don't have to login any time to run that.

With the default script you can just connect to your wireless network and establish a static IP address to access later through SSH, you will not login into your Raspberry Pi to enable this connection.

Or alse you can delete the contento of the `rpi-do-on-start.sh` file to start building your own script.

## Requirements

* A Raspberry Pi (Tested in the models 2b and 4b)
* A Linux host to run the instalation script into the microsd (all examples where done on Kubuntu 18.04)
* The Raspberry Pi OS image (tests performed with buster version)

## Procedure

1. Clone this repo to the host pc, for instance the pc where you will install the image in the microsd.
1. Mount the Raspberry Pi OS image in the microsd
  1. You can follow this tutorial with the `dd` command -> https://www.raspberrypi.org/documentation/installation/installing-images/linux.md
1. With the `lsblk` command you can see the microsd partition where the root filesystem of the image was installed
```
sdd      8:48   1  29,8G  0 disk
├─sdd1   8:49   1   256M  0 part
└─sdd2   8:50   1  29,6G  0 part
```
1. In this case the `sdd2` partition is the one that contains the Raspberry Pi OS root filesystem, you have to mount this partition, you can use any file system explorer like Dolphin or mounting this with the mount command
  1. example with the `mount` command
```
mkdir /media/user1/rootfs
mount /dev/sdd2 /media/user1/rootfs
```
1. Project configuration
  1. **rpi-do-on-start.sh**: Save all your script that you want to run once as soon as the system startup (you can delete the current content or reuse them, below it is indicated how to parametrize this)
  1. **install-rpi-script.sh**: Install your script in the microsd
  ```
cd cloned_project_path
# 1st param: Path to the mounted microsd root filesystem
./install-rpi.script.sh /media/user1/rootfs
```
1. Synchroinze and unmount the microsd
1. Connect the microsd to the Raspberry Pi and start it

With these steps you will have your script run on the Raspberry Pi without having to login to it.

If you have a Raspberry Pi to which you do not have access but you can give someone the microsd to start it, you could with the following example automatically connect it to the network, allowing you to access remotely via SSH.

## Default Configuration

The `script rpi-do-on-start.sh` file provides by default what is necessary to automatically connect your Raspberry Pi without login, even if the microsd has been installed and never started.

### Automatic connection to Wireless Network

To connect the RPI automatically to the Wireless Network you will only have to set the variable `wifi_scid` with the name of your wireless network and `wifi_pwd` with the respective password, keepp in mind that even if the password is not encrypted in the script, in the OS configuration it will be encrypted with the command `wpa_passphrase`, and once the configuration is done, all the files of this project are deleted from the microsd

*This requires having the two variables set to perform this configuration*

### Setting a static IP

By setting the following variables, a static IP will be established in the Raspberry PI
* `lan_ip` IP / (slash) Mask (e.g. 192.168.1.10/24)
* `lan_gw` Default gateway IP (e.g. 192.168.1.1)
* `lan_dns` DNS IP (e.g. 8.8.8.8)

*This requires having the three variables set to perform this configuration*

## Behavior

This script mounts a Systemd service to microsd and enables multi-user.target.wants with a symbolic link to start automatically.
When starting the OS it will execute a launcher script that will execute the script `rpi-do-on-start.sh` and at the end it will remove itself and the Systemd service.
