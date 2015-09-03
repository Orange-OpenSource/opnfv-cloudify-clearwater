#!/bin/bash

ctx logger debug "${COMMAND}"

ip=$(ctx source instance host_ip)
name=$(ctx source instance id)


cd /usr/share/cacti/cli

# Get the id device from the name
id=`sudo ./remove_device.php --list-devices | grep $name | cut -f1`

# Delete the host
sudo ./remove_device.php --device-id=$id