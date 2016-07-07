#!/bin/bash -e


if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes

#/usr/share/clearwater/clearwater-etcd/scripts/wait_for_etcd
#sudo /usr/share/clearwater/clearwater-config-manager/scripts/upload_shared_config

