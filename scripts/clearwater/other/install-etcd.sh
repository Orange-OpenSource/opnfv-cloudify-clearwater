#!/bin/bash -e

ctx logger debug "${COMMAND}"

release=$(ctx node properties release)

ctx logger info "Configure the APT software source"
if [ ! -f /etc/apt/sources.list.d/clearwater.list ]
  then
    if [ $release = "stable" ]
    then
      echo 'deb http://repo.cw-ngv.com/stable binary/' | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    else
      echo "deb http://repo.cw-ngv.com/archive/$release binary/" | sudo tee --append /etc/apt/sources.list.d/clearwater.list
    fi
    curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
fi
sudo apt-get update

ctx logger info "Now install the software"
sudo DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
ctx logger info "The software is installed"

/usr/share/clearwater/clearwater-etcd/scripts/wait_for_etcd
sudo /usr/share/clearwater/clearwater-config-manager/scripts/upload_shared_config
# sudo /usr/share/clearwater/clearwater-config-manager/scripts/apply_shared_config

ctx logger info "Installation is done"
