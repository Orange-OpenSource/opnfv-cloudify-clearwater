#!/bin/bash -e

ctx logger debug "${COMMAND}"

ctx logger info "Configure the APT software source with the new release"
if [ -f /etc/apt/sources.list.d/clearwater.list ]
  then
    sudo rm /etc/apt/sources.list.d/clearwater.list
fi

if [ $release = "stable" ]
then
  echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
else
  echo "deb http://repo.cw-ngv.com/archive/$release binary/" | sudo tee --append /etc/apt/sources.list.d/clearwater.list
fi

ctx logger info "Upgrade clearwater packages"
sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/clearwater.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"

sudo apt-get install clearwater-infrastructure

sudo clearwater-upgrade
